//
//  ARLandmarker.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import ARKit
import CoreLocation

public protocol ARLandmarkerDelegate: class {
    /// Called when the user taps an ARLandmark
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) -> Void
    
    /// Called whenever the landmarker is about to display an updated landmark.
    ///
    /// If `landmarkDisplayer(_:willUpdate:for:) -> UIView?` is implemented, this is given precendence over that method.
    ///
    /// - Parameters:
    ///   - landmarkDisplayer: The landmark displayer.
    ///   - landmark: The landmark being updated.
    /// - Returns: A new image to display at the landmark, or `nil` to keep the existing image.
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, willUpdate landmark: ARLandmark, for location: CLLocation) -> UIImage?
    
    /// Called whenever the landmarker is about to display an updated landmark.
    ///
    /// If `landmarkDisplayer(_:willUpdate:for:) -> UIImage?` is implemented, it is given precendence over this method.
    ///
    /// - Parameters:
    ///   - landmarkDisplayer: The landmark displayer.
    ///   - landmark: The landmark being updated.
    /// - Returns: A new view to display at the landmark, or `nil` to keep the existing view.
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, willUpdate landmark: ARLandmark, for location: CLLocation) -> UIView?
    
    /// Called when something causes the landmark displayer to fail
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didFailWithError error: Error) -> Void
}

public extension ARLandmarkerDelegate {
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, didTap landmark: ARLandmark) -> Void { }
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, willUpdate landmark: ARLandmark, for location: CLLocation) -> UIImage? { return nil }
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarker, willUpdate landmark: ARLandmark, for location: CLLocation) -> UIView? { return nil }
}

public class ARLandmarker: NSObject {
    /// A callback to indicate when the addition of an ARLandmark has finished processing
    /// - parameter landmark: The data representing the landmark in the AR World
    public typealias LandmarkCallback = (_ landmark: ARLandmark?) -> Void
    /// The distance, in meters, the device can travel away from the last world origin before a new world origin is calculated. It is a programmer error to set this to more than 90. Defaults to 10. Recommended range is 5 - 30.
    public var worldRecenteringThreshold: CLLocationDistance = 10
    
    /// The maximum distance from the AR World's origin at which ARKit will display an ARAnchor
    private let ARKitMaximumVisibleAnchorDistance: CLLocationDistance = 90
    /// The maximum distance from the AR World's origin at which to project an ARAnchor
    private var maximumAnchorDistance: CLLocationDistance {
        // Note: If `worldRecenteringThreshold` is greater than `0.5`*`ARKitMaximumVisibleAnchorDistance`,
        // then landmarks in front of the device may appear behind it.
        return ARKitMaximumVisibleAnchorDistance - worldRecenteringThreshold
    }
    
    /// The smallest scaling factor that should be applied to the AR views. Defaults to 1.0
    public var minViewScale: CGFloat = 0.5
    
    /// The nearest distance, in meters, at which AR views should appear at `minViewScale`. Defaults to .greatestFiniteMagnitude.
    public var maxViewScaleDistance: CLLocationDistance = .greatestFiniteMagnitude
    
    /// The nearest distance at which AR views will be shown. Defaults to 0.
    public var minumumVisibleDistance: CLLocationDistance = 0
    
    /// The farthest distance at which AR views will be shown. Defaults to .greatestFiniteMagnitude.
    public var maximumVisibleDistance: CLLocationDistance = .greatestFiniteMagnitude
    
    /// The strategy to employ when ARLandarks overlap. Defaults to .showAll.
    public var overlappingLandmarksStrategy: OverlappingARLandmarkStrategy = .showAll
    
    /// The minimum distance that must be travelled before calling the delegate's `landmarkDisplayer(_:willUpdate:)` method. Defaults to 0.
    public var minimumDistanceBetweenLandmarkViewUpdates: CLLocationDistance = 0
    private var lastLandmarkViewUpdateLocation: CLLocation?
    
    /// The maximum uncertainty on a new location in order to recenter the world origin.
    public var maximumWorldRecenteringLocationUncertainty: CLLocationAccuracy = .greatestFiniteMagnitude
    
    /// The view containing all the AR content. Should be added as a subview to some visible viewController.
    public let view: ARSKView
    
    /// The scene that renders AR components and captures user interaction.
    public let scene: InteractiveScene
    
    /// The CLLocationManager used to receive user location updates.
    public let locationManager: CLLocationManager
    
    /// The object to receive updates about the landmarker's state, including errors.
    public var delegate: ARLandmarkerDelegate?
    
    /// The object used to check the AVCaptureDevice authorization status.
    public var captureDeviceAuthorizer: AVCaptureDeviceAuthorizer.Type = AVCaptureDevice.self
    
    /// The landmarks currently being managed by the `ARLandmarker`.
    public var currentLandmarks: [ARLandmark] {
        return landmarks.values.map({ $0 })
    }
    
    /// The current origin of the AR World
    private(set) var worldOrigin: CLLocation?
    
    private var landmarks: [ARAnchor: ARLandmark] = [:]
    private var pendingLandmarkRequests: [(userInfo: [String: Any], image: UIImage, location: CLLocation, completion: LandmarkCallback?)] = []
    
    /// - parameter view: A view in which to present the scene
    /// - parameter scene: A scene in which to show the AR content
    /// - parameter locationManager: A configured CLLocationManager
    public init(view: ARSKView, scene: InteractiveScene, locationManager: CLLocationManager) {
        self.view = view
        self.scene = scene
        self.locationManager = locationManager
        super.init()
        setupView()
        configureLocationManager()
        //        view.showsPhysics = true
        //        view.showsFPS = true
        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = .zero
    }
    
    /// Add an image into the AR World
    /// - parameter image: The image to add to the AR World
    /// - parameter location: The real-world location at which the image should be displayed
    /// - parameter completion: Called when the view has been added.
    public func addLandmark(userInfo: [String: Any] = [:], image: UIImage, at location: CLLocation, completion: LandmarkCallback?) {
        createLandmark(userInfo: userInfo, image: image, at: location, completion: completion)
    }
    
    /// Add a view into the AR World.
    /// - parameter view: The view to add to the AR World. It will be interpreted as a static image.
    /// - parameter location: The real-world location at which the view should be displayed
    /// - parameter completion: Called when the view has been added.
    public func addLandmark(userInfo: [String: Any] = [:], view: UIView, at location: CLLocation, completion: LandmarkCallback?) {
        guard let image = view.toImage() else {
            completion?(nil)
            return
        }
        addLandmark(userInfo: userInfo, image: image, at: location, completion: completion)
    }
    
    /// Remove all landmarks from the AR World
    public func removeAllLandmarks() {
        landmarks.keys.forEach({ (anchor) in
            view.node(for: anchor)?.removeFromParent()
            view.node(for: anchor)?.children.forEach({ $0.removeFromParent() })
            view.session.remove(anchor: anchor)
        })
        landmarks = [:]
    }
    
    /// Remove a landmark from the AR World.
    /// - parameter landmark: The landmark to remove.
    /// - returns: `true` if the landmark existed and was removed, `false` if the landmark did not exist.
    public func remove(landmark: ARLandmark) -> Bool {
        if let anchor = landmarks.keys.first(where: { $0.identifier == landmark.id }) {
            view.node(for: anchor)?.removeFromParent()
            view.session.remove(anchor: anchor)
            landmarks[anchor] = nil
            return true
        } else {
            return false
        }
    }
    
    /// Request the `ARLandmarkDisplayer` to start checking for overlapping landmark views, and to use `overlappingLandmarksStrategy` to evaluate them.
    /// - parameter interval: The seconds between each check
    public func beginEvaluatingOverlappingLandmarks(atInterval interval: TimeInterval) -> Void {
        scene.startCheckingForNodeIntersections(atInterval: interval, atGeneration: 1)
    }
    
    /// Request the `ARLandmarkDisplayer` to check for overlapping landmark views, and to use `overlappingLandmarksStrategy` to evaluate them.
    public func evaluateOverlappingLandmarks() -> Void {
        let (intersections, independents) = scene.intersectingNodes(searchGeneration: 1)
        interactiveScene(scene, hasIntersectingNodes: intersections, notIntersecting: independents, atGeneration: 1)
    }
    
    /// Request the `ARLandmarkDisplayer` to stop checking for overlapping landmark views.
    public func stopEvaluatingOverlappingLandmarks() -> Void {
        scene.stopCheckingForNodeIntersections()
    }
}

extension ARLandmarker {
    private func setupView() {
        view.delegate = self
        view.presentScene(scene)
        scene.interactionDelegate = self
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
    }
    
    private func updateWorldOrigin(_ origin: CLLocation) {
        captureDeviceAuthorizer.requestAccess(for: .video) { [weak self] (granted) in
            guard granted else {
                return
            }
            DispatchQueue.main.async {
                let landmarksCopy = self?.landmarks.values.map({ $0 }) ?? []
                self?.removeAllLandmarks()
                
                // Move the AR World origin
                let configuration = ARWorldTrackingConfiguration()
                configuration.worldAlignment = .gravityAndHeading
                self?.view.session.run(configuration, options: [.resetTracking])
                self?.worldOrigin = origin
                
                // Replace all the landmarks
                self?.addPendingLandmarks()
                landmarksCopy.forEach({ (landmark) in
                    self?.createLandmark(userInfo: landmark.userInfo, image: landmark.image, at: landmark.location, completion: nil)
                })
            }
        }
    }
    
    private func createLandmark(userInfo: [String: Any], image: UIImage, at location: CLLocation, completion: LandmarkCallback?) {
        guard let origin = worldOrigin else {
            pendingLandmarkRequests.append((userInfo: userInfo, image: image, location: location, completion: completion))
            return
        }
        
        makeARAnchor(from: origin, to: location) { [weak self] anchor in
            let landmark = ARLandmark(userInfo: userInfo, image: image, location: location, id: anchor.identifier)
            self?.landmarks[anchor] = landmark
            self?.view.session.add(anchor: anchor)
            completion?(landmark)
        }
    }
    
    private func addPendingLandmarks() {
        for landmarkRequest in pendingLandmarkRequests {
            createLandmark(userInfo: landmarkRequest.userInfo, image: landmarkRequest.image, at: landmarkRequest.location, completion: landmarkRequest.completion)
        }
        pendingLandmarkRequests = []
    }
    
    /// Create the matrix that transforms `location` to `landmark`.
    private func makeARAnchor(from location: CLLocation, to landmark: CLLocation, completion: @escaping (ARAnchor) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let maximumAnchorDistance = self?.maximumAnchorDistance ?? 75
            // Calculate the displacement
            let distance = location.distance(from: landmark)
            let distanceTransform = simd_float4x4.translatingIdentity(x: 0, y: 0, z: -Float(min(distance, maximumAnchorDistance)))
            // Calculate the horizontal rotation
            let rotation = Matrix.angle(from: location, to: landmark)
            // Calculate the vertical tilt
            let tilt = Matrix.angleOffHorizon(from: location, to: landmark)
            // Apply the transformations
            let tiltedTransformation = Matrix.rotateVertically(matrix: distanceTransform, around: tilt)
            let completedTransformation = Matrix.rotateHorizontally(matrix: tiltedTransformation, around: -rotation)
            DispatchQueue.main.async {
                let anchor = ARAnchor(transform: completedTransformation)
                completion(anchor)
            }
        }
    }
}

extension ARLandmarker: ARSKViewDelegate {
    public func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let landmark = self?.landmarks[anchor] else {
                return
            }
            let landmarkNode = SKSpriteNode(texture: SKTexture(image: landmark.image))
            landmarkNode.name = landmark.id.uuidString
            self?.updateLandmarkNode(landmarkNode, with: landmark, parent: node, location: self?.locationManager.location)
            //            landmarkNode.physicsBody = SKPhysicsBody(circleOfRadius: 100)
            //            landmarkNode.physicsBody?.categoryBitMask = 0x00000001
            node.addChild(landmarkNode)
        }
    }
    
    fileprivate func updateLandmarkNode(_ landmarkNode: SKSpriteNode, with landmark: ARLandmark, parent: SKNode, location: CLLocation?) {
        let distance = location?.distance(from: landmark.location) ?? 0
        parent.zPosition = CGFloat(1.0 / distance)
        let scaleRange = 1 - minViewScale
        let distanceRatio = CGFloat(max(maxViewScaleDistance - distance, 0.0) / maxViewScaleDistance)
        let scale = ((distanceRatio * scaleRange) + minViewScale) // * arKitInverseScale
        landmarkNode.setScale(scale)
        if distance < minumumVisibleDistance || distance > maximumVisibleDistance {
            landmarkNode.isHidden = true
            //            landmarkNode.physicsBody?.categoryBitMask = 0
        } else {
            //            landmarkNode.physicsBody?.categoryBitMask = 0x00000001
        }
    }
    
    public func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor) {
        node.setScale(1)
    }
}

extension ARLandmarker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateAnchorNodes(with: location)
        }
        if let location = locations.filter({ $0.horizontalAccuracy <= maximumWorldRecenteringLocationUncertainty }).last {
            if worldOrigin == nil || abs(worldOrigin!.distance(from: location)) > worldRecenteringThreshold {
                updateWorldOrigin(location)
            }
        }
    }
    
    private func updateAnchorNodes(with location: CLLocation) {
        for (anchor, landmark) in landmarks {
            guard let node = view.node(for: anchor),
                let landmarkNode = node.childNode(withName: anchor.identifier.uuidString) as? SKSpriteNode else {
                    return
            }
            updateLandmarkNode(landmarkNode, with: landmark, parent: node, location: location)
            
            if lastLandmarkViewUpdateLocation?.distance(from: location) ?? .greatestFiniteMagnitude > minimumDistanceBetweenLandmarkViewUpdates {
                var image: UIImage?
                if let newImage: UIImage = self.delegate?.landmarkDisplayer(self, willUpdate: landmark, for: location) {
                    image = newImage
                } else if let newView: UIView = self.delegate?.landmarkDisplayer(self, willUpdate: landmark, for: location), let newImage = newView.toImage() {
                    image = newImage
                }
                DispatchQueue.global(qos: .userInteractive).async {
                    if let textureImage = image {
                        landmarkNode.texture = SKTexture(image: textureImage)
                    }
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.landmarkDisplayer(self, didFailWithError: CLError(.denied))
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.landmarkDisplayer(self, didFailWithError: error)
    }
}

extension ARLandmarker: InteractiveSceneDelegate {
    func interactiveScene(_ scene: InteractiveScene, didTap nodes: [SKNode]) {
        for node in nodes {
            if let anchorNode = anchorNode(for: node, at: 1), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
                delegate?.landmarkDisplayer(self, didTap: landmark)
            }
        }
    }
    
    func interactiveScene(_ scene: InteractiveScene, hasIntersectingNodes intersecting: [[SKNode]], notIntersecting independents: [SKNode], atGeneration generation: UInt) {
        func isRendered(_ node: SKNode) -> Bool {
            let distanceAway = distance(node)
            return distanceAway >= minumumVisibleDistance && distanceAway <= maximumVisibleDistance
        }
        func distance(_ node: SKNode) -> CLLocationDistance {
            var distance: Double = 0
            if let origin = worldOrigin, let anchorNode = anchorNode(for: node, at: generation), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
                distance = origin.distance(from: landmark.location)
            }
            return distance
        }
        switch overlappingLandmarksStrategy {
        case .showAll:
            intersecting.flatMap({ $0 }).filter({ isRendered($0) }).forEach({ $0.isHidden = false })
            independents.filter({ isRendered($0) }).forEach({ $0.isHidden = false })
        case .showNearest:
            intersecting.forEach { (nodes) in
                let sorted = nodes.filter({ isRendered($0) }).sorted(by: { distance($0) <= distance($1) })
                sorted.forEach({ $0.isHidden = true })
                sorted.first?.isHidden = false
            }
            independents.filter({ isRendered($0) }).forEach({ $0.isHidden = false })
        case .showFarthest:
            intersecting.forEach { (nodes) in
                let sorted = nodes.filter({ isRendered($0) }).sorted(by: { distance($0) <= distance($1) })
                sorted.forEach({ $0.isHidden = true })
                sorted.last?.isHidden = false
            }
            independents.filter({ isRendered($0) }).forEach({ $0.isHidden = false })
        case .custom(let callback):
            let arLandmarks = intersecting.map { (nodes) -> [ARLandmark] in
                return nodes.compactMap({ (node) -> ARLandmark? in
                    if isRendered(node), let anchorNode = anchorNode(for: node, at: generation), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
                        return landmark
                    } else {
                        return nil
                    }
                })
            }
            let freeLandmarks = independents.compactMap { (node) -> ARLandmark? in
                if isRendered(node), let anchorNode = anchorNode(for: node, at: generation), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
                    return landmark
                } else {
                    return nil
                }
            }
            callback(arLandmarks, freeLandmarks)
        }
    }
    
    private func anchorNode(for node: SKNode, at generation: UInt) -> SKNode? {
        var node: SKNode? = node
        for _ in 0..<generation {
            node = node?.parent
        }
        return node
    }
}

extension ARLandmarker: SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {
        // TODO: Use something like this for landmark collisions.
    }
}

public protocol AVCaptureDeviceAuthorizer {
    static func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void)
}

extension AVCaptureDevice: AVCaptureDeviceAuthorizer { }
