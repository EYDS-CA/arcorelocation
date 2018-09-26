//
//  ARLandmarker.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import ARKit
import CoreLocation

public class ARLandmarker: NSObject, ARLandmarkDisplayer {
    /// The distance, in meters, the device can travel away from the last world origin before a new world origin is calculated. It is a programmer error to set this to more than 90. Defaults to 10. Recommended range is 5 - 30.
    public var worldRecenteringThreshold: Double = 10
    
    /// The maximum distance from the AR World's origin at which ARKit will display an ARAnchor
    private let ARKitMaximumVisibleAnchorDistance: Double = 90
    /// The maximum distance from the AR World's origin at which to project an ARAnchor
    private var maximumAnchorDistance: Double {
        return ARKitMaximumVisibleAnchorDistance - worldRecenteringThreshold
    }
    
    /// The smallest scaling factor that should be applied to the AR views. Defaults to 1.0
    public var minViewScale: CGFloat = 0.5
    
    /// The nearest distance, in meters, at which AR views should appear at `minViewScale`. Defaults to .greatestFiniteMagnitude.
    public var maxViewScaleDistance: Double = .greatestFiniteMagnitude
    
    /// The nearest distance at which AR views will be shown. Defaults to 0.
    public var minumumVisibleDistance: Double = 0
    
    /// The farthest distance at which AR views will be shown. Defaults to .greatestFiniteMagnitude.
    public var maximumVisibleDistance: Double = .greatestFiniteMagnitude
    
    /// The strategy to employ when ARLandarks overlap. Defaults to .showAll.
    public var overlappingLandmarksStrategy: OverlappingARLandmarkStrategy = .showAll
    
    /// The view containing all the AR content. Should be added as a subview to some visible viewController.
    public let view: ARSKView
    
    /// The scene that renders AR components and captures user interaction.
    public let scene: InteractiveScene
    
    /// The CLLocationManager used to receive user location updates.
    public let locationManager: CLLocationManager
    
    /// The object to receive updates about the landmarker's state, including errors.
    public var delegate: ARLandmarkDisplayerDelegate?
    
    /// The object used to check the AVCaptureDevice authorization status.
    public var captureDeviceAuthorizer: AVCaptureDeviceAuthorizer.Type = AVCaptureDevice.self
    
    /// The landmarks currently being managed by the `ARLandmarker`.
    public var currentLandmarks: [ARLandmark] {
        return landmarks.values.map({ $0 })
    }
    
    /// The current origin of the AR World
    private(set) var worldOrigin: CLLocation?
    
    private var landmarks: [ARAnchor: ARLandmark] = [:]
    
    /// - parameter view: A view in which to present the scene
    /// - parameter scene: A scene in which to show the AR content
    /// - parameter locationManager: A configured CLLocationManager
    init(view: ARSKView, scene: InteractiveScene, locationManager: CLLocationManager) {
        self.view = view
        self.scene = scene
        self.locationManager = locationManager
        super.init()
        setupView()
        configureLocationManager()
    }
    
    public func addLandmark(image: UIImage, at location: CLLocation, completion: LandmarkCallback?) {
        guard let origin = worldOrigin else {
            completion?(nil)
            return
        }
        
        makeARAnchor(from: origin, to: location) { [weak self] anchor in
            self?.view.session.add(anchor: anchor)
            let landmark = ARLandmark(image: image, location: location, id: anchor.identifier)
            self?.landmarks[anchor] = landmark
            completion?(landmark)
        }
    }
    
    public func addLandmark(view: UIView, at location: CLLocation, completion: LandmarkCallback?) {
        guard let image = view.toImage() else {
            return
        }
        addLandmark(image: image, at: location, completion: completion)
    }
    
    public func removeAllLandmarks() {
        landmarks.keys.forEach({ (anchor) in
            view.node(for: anchor)?.removeFromParent()
            view.session.remove(anchor: anchor)
        })
        landmarks = [:]
    }
    
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
        guard captureDeviceAuthorizer.authorizationStatus(for: .video) == .authorized else {
            return
        }
        let landmarksCopy = landmarks.values.map({ $0 })
        removeAllLandmarks()
        
        // Move the AR World origin
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        view.session.run(configuration, options: [.resetTracking])
        worldOrigin = origin
        
        // Replace all the landmarks
        landmarksCopy.forEach({ (landmark) in
            addLandmark(image: landmark.image, at: landmark.location, completion: nil)
        })
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
        guard let landmark = landmarks[anchor] else {
            return
        }
        let landmarkNode = SKSpriteNode(texture: SKTexture(image: landmark.image))
        landmarkNode.name = landmark.id.uuidString
        node.addChild(landmarkNode)
    }
    
    public func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor) {
        guard let landmarkNode = node.childNode(withName: anchor.identifier.uuidString), let landmark = landmarks[anchor] else {
            return
        }
        // ARKit scales each node based on its anchor's distance from the origin.
        // Override this behavior by inverting the scale computed by ARKit
        let arKitInverseScale = 1 / abs(node.yScale)
        let distance = worldOrigin?.distance(from: landmark.location) ?? 0
        node.zPosition = CGFloat(1 / distance)
        let scaleRange = 1 - minViewScale
        let distanceRatio = CGFloat(max(maxViewScaleDistance - distance, 0.0) / maxViewScaleDistance)
        let scale = ((distanceRatio * scaleRange) + minViewScale) * arKitInverseScale
        landmarkNode.setScale(scale)
    }
}

extension ARLandmarker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if worldOrigin == nil || abs(worldOrigin!.distance(from: location)) > worldRecenteringThreshold {
                updateWorldOrigin(location)
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
        switch overlappingLandmarksStrategy {
        case .showAll:
            intersecting.flatMap({ $0 }).forEach({ $0.isHidden = false })
            independents.forEach({ $0.isHidden = false })
        case .showNearest:
            intersecting.forEach { (nodes) in
                let sorted = nodes.sorted(by: { $0.zPosition >= $1.zPosition })
                sorted.forEach({ $0.isHidden = true })
                sorted.first?.isHidden = false
            }
            independents.forEach({ $0.isHidden = false })
        case .showFarthest:
            intersecting.forEach { (nodes) in
                let sorted = nodes.sorted(by: { $0.zPosition >= $1.zPosition })
                sorted.forEach({ $0.isHidden = true })
                sorted.last?.isHidden = false
            }
            independents.forEach({ $0.isHidden = false })
        case .custom(let callback):
            let arLandmarks = intersecting.map { (nodes) -> [ARLandmark] in
                return nodes.compactMap({ (node) -> ARLandmark? in
                    if let anchorNode = anchorNode(for: node, at: generation), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
                        return landmark
                    } else {
                        return nil
                    }
                })
            }
            let freeLandmarks = independents.compactMap { (node) -> ARLandmark? in
                if let anchorNode = anchorNode(for: node, at: generation), let anchor = view.anchor(for: anchorNode), let landmark = landmarks[anchor] {
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

public protocol AVCaptureDeviceAuthorizer {
    static func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
}

extension AVCaptureDevice: AVCaptureDeviceAuthorizer { }
