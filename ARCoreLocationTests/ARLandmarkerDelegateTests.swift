//
//  ARLandmarkerDelegateTests.swift
//  ARCoreLocationTests
//
//  Created by Skyler Smith on 2018-09-25.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import XCTest
import CoreLocation
import SpriteKit
import ARKit

class ARLandmarkerDelegateTests: ARLandmarkerLandmarkTests {

    var session: MockARSession {
        return view.mockSession
    }
    
    var delegate: MockLandmarkerDelegate!
    
    override func setUp() {
        super.setUp()
        delegate = MockLandmarkerDelegate()
        landmarker.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        super.tearDown()
    }

    func testAddLandmarkNodeForAnchor() {
        // Given
        let location = CLLocation(latitude: 40.7707, longitude: -111.8911)
        let image = UIImage()
        var landmark: ARLandmark?
        
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { arLandmark in
            landmark = arLandmark
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
        let anchor = session.anchors.first!
        let node = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
        
        // When
        landmarker.view(view, didAdd: node, for: anchor)
        
        // Then
        XCTAssertEqual(session.anchors.count, 1)
        XCTAssertEqual(node.children.count, 1)
        XCTAssertEqual(node.children.first?.name, anchor.identifier.uuidString)
        XCTAssertEqual(anchor.identifier, landmark?.id)
    }
    
    func testDoNotAddLandmarkNodeForInvalidAnchor() {
        // Given
        let node = SKSpriteNode(color: .green, size: CGSize(width: 10, height: 10))
        let anchor = ARAnchor(transform: simd_float4x4(1))
        
        // When
        landmarker.view(view, didAdd: node, for: anchor)
        
        // Then
        XCTAssertTrue(node.children.isEmpty)
    }
    
    func testScaleNode() {
        // Given
        let location = CLLocation(latitude: 40.7707, longitude: -111.8911)
        let image = UIImage()
        let distance = location.distance(from: startLocation)
        
        let minViewScale: CGFloat = 0.1
        landmarker.minViewScale = minViewScale
        landmarker.maxViewScaleDistance = distance / 2
        
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { _ in
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
        
        let anchor = session.anchors.first!
        let node = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
        landmarker.view(view, didAdd: node, for: anchor)
        let landmarkNode = node.children.first!
        
        // When
        landmarker.view(view, didUpdate: node, for: anchor)
        
        // Then
        XCTAssertEqual(landmarkNode.xScale, minViewScale, accuracy: 0.0001, "Incorrectly scaled image")
    }
    
    func testDoNotScaleNode() {
        // Given
        let location = startLocation
        let image = UIImage()
        
        let minViewScale: CGFloat = 0.1
        landmarker.minViewScale = minViewScale
        landmarker.maxViewScaleDistance = 200
        
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { _ in
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.0)
        
        let anchor = session.anchors.first!
        let node = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
        landmarker.view(view, didAdd: node, for: anchor)
        let landmarkNode = node.children.first!
        
        // When
        landmarker.view(view, didUpdate: node, for: anchor)
        
        // Then
        XCTAssertEqual(landmarkNode.xScale, 1.0, accuracy: 0.0001, "Incorrectly scaled image at 0 distance which should not be scaled")
    }
    
    func testUpdateLocation() {
        // Given
        let location = CLLocation(latitude: 40.6755, longitude: -74.0521)
        let image = UIImage()
        var landmark: ARLandmark?
        
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { (arLandmark) in
            landmark = arLandmark
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(landmarker.currentLandmarks.count, 1)
        
        // When
        landmarker.locationManager(locationManager, didUpdateLocations: [CLLocation(latitude: 40.6884, longitude: -74.046)])
        let worldOriginSetPromise = expectation(description: "set world origin")
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.01) {
            worldOriginSetPromise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        
        // Then
        XCTAssertEqual(landmarker.currentLandmarks.count, 1)
        XCTAssertFalse(landmarker.currentLandmarks.contains(where: { $0.id == landmark?.id }))
        XCTAssertEqual(landmarker.currentLandmarks.first?.location, landmark?.location)
        XCTAssertEqual(landmarker.currentLandmarks.first?.image, landmark?.image)
    }
    
    func testSendErrorWithLocationAuthorizationDenied() {
        // Given
        
        // When
        landmarker.locationManager(locationManager, didChangeAuthorization: .denied)
        
        // Then
        XCTAssertNotNil(delegate.error)
    }
    
    func testSendErrorWithLocationManagerFailure() {
        // Given
        let error = CLError(.geocodeFoundNoResult)
        
        // When
        landmarker.locationManager(locationManager, didFailWithError: error)
        
        // Then
        XCTAssertEqual(delegate.error as? CLError, error)
    }
    
    func testRelaysTappedLandmark() {
        // Given
        let location = CLLocation(latitude: 41, longitude: -37)
        let image = UIImage()
        var landmark: ARLandmark?
        let parentNode = SKSpriteNode(color: .clear, size: .zero)
        
        let promise = expectation(description: "Adds Landmark")
        landmarker.addLandmark(image: image, at: location) { (arLandmark) in
            landmark = arLandmark
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
        
        session.anchorNodes[session.anchors.first!] = parentNode
        landmarker.view(view, didAdd: parentNode, for: session.anchors.first!)
        let landmarkNode = parentNode.children.first!
        
        // When
        landmarker.interactiveScene(scene, didTap: [landmarkNode])
        
        // Then
        XCTAssertEqual(delegate.tappedLandmark?.id, landmark?.id)
    }
    
    func testShowsAllNodes() {
        // Given
        let node1 = SKSpriteNode(color: .white, size: .zero)
        let node2 = SKSpriteNode(color: .white, size: .zero)
        let node3 = SKSpriteNode(color: .white, size: .zero)
        let node4 = SKSpriteNode(color: .white, size: .zero)
        let node5 = SKSpriteNode(color: .white, size: .zero)
        
        let nodes = [node1, node2, node3, node4, node5]
        nodes.forEach({ $0.isHidden = true })
        
        landmarker.overlappingLandmarksStrategy = .showAll
        
        // When
        landmarker.interactiveScene(scene, hasIntersectingNodes: [[node1, node2], [node3, node4]], notIntersecting: [node5], atGeneration: 1)
        
        // Then
        XCTAssertFalse(nodes.contains(where: { $0.isHidden }))
    }
    
    func testShowsNearestNode() {
        // Given
        let node1 = SKSpriteNode(color: .white, size: .zero)
        let node2 = SKSpriteNode(color: .white, size: .zero)
        let node3 = SKSpriteNode(color: .white, size: .zero)
        let node4 = SKSpriteNode(color: .white, size: .zero)
        let node5 = SKSpriteNode(color: .white, size: .zero)
        
        node1.zPosition = 4
        node2.zPosition = 8
        node3.zPosition = 5
        node4.zPosition = 10
        node5.zPosition = 0
        
        landmarker.overlappingLandmarksStrategy = .showNearest
        
        // When
        landmarker.interactiveScene(scene, hasIntersectingNodes: [[node1, node2, node3, node4]], notIntersecting: [node5], atGeneration: 1)
        
        // Then
        XCTAssertFalse(node4.isHidden)
        XCTAssertFalse(node5.isHidden)
        XCTAssertFalse([node1, node2, node3].contains(where: { !$0.isHidden }))
    }
    
    func testShowsFarthestNode() {
        // Given
        let node1 = SKSpriteNode(color: .white, size: .zero)
        let node2 = SKSpriteNode(color: .white, size: .zero)
        let node3 = SKSpriteNode(color: .white, size: .zero)
        let node4 = SKSpriteNode(color: .white, size: .zero)
        let node5 = SKSpriteNode(color: .white, size: .zero)
        
        node1.zPosition = 4
        node2.zPosition = 8
        node3.zPosition = 5
        node4.zPosition = 10
        node5.zPosition = 0
        
        landmarker.overlappingLandmarksStrategy = .showFarthest
        
        // When
        landmarker.interactiveScene(scene, hasIntersectingNodes: [[node1, node2, node3, node4]], notIntersecting: [node5], atGeneration: 1)
        
        // Then
        XCTAssertFalse(node1.isHidden)
        XCTAssertFalse(node5.isHidden)
        XCTAssertFalse([node2, node3, node4].contains(where: { !$0.isHidden }))
    }
    
    func testForwardsCustomInsersections() {
        // Given
        let locations = [CLLocation(latitude: 41, longitude: -37), CLLocation(latitude: 42, longitude: -38), CLLocation(latitude: 40, longitude: -37)]
        let image = UIImage()
        var landmarks: [ARLandmark] = []
        let parentNodes = [SKSpriteNode(color: .clear, size: .zero), SKSpriteNode(color: .black, size: .zero), SKSpriteNode(color: .white, size: .zero)]
        
        let promise1 = expectation(description: "Adds Landmark 1")
        landmarker.addLandmark(image: image, at: locations[0]) { (landmark) in
            landmarks.append(landmark!)
            promise1.fulfill()
        }
        let promise2 = expectation(description: "Adds Landmark 2")
        landmarker.addLandmark(image: image, at: locations[1]) { (landmark) in
            landmarks.append(landmark!)
            promise2.fulfill()
        }
        let promise3 = expectation(description: "Adds Landmark 3")
        landmarker.addLandmark(image: image, at: locations[2]) { (landmark) in
            landmarks.append(landmark!)
            promise3.fulfill()
        }
        wait(for: [promise1, promise2, promise3], timeout: 1.0)
        
        session.anchorNodes[session.anchors[0]] = parentNodes[0]
        landmarker.view(view, didAdd: parentNodes[0], for: session.anchors[0])
        session.anchorNodes[session.anchors[1]] = parentNodes[1]
        landmarker.view(view, didAdd: parentNodes[1], for: session.anchors[1])
        session.anchorNodes[session.anchors[2]] = parentNodes[2]
        landmarker.view(view, didAdd: parentNodes[2], for: session.anchors[2])
        
        let landmarkNodes = parentNodes.map({ $0.children.first! })
        
        let didCallCustom = expectation(description: "Did use custom intersection callback")
        landmarker.overlappingLandmarksStrategy = .custom(callback: { (intersecting, independent) in
            // Then
            XCTAssertEqual(intersecting.count, 1)
            XCTAssertEqual(intersecting.first?.count, 2)
            XCTAssertTrue(intersecting.contains(where: { intersection in
                return intersection.contains(where: { $0.id.uuidString == landmarkNodes[0].name }) && intersection.contains(where: { $0.id.uuidString == landmarkNodes[1].name })
            }), "\(intersecting.first!.map({ $0.id.uuidString })) Does not equal \([landmarkNodes[0], landmarkNodes[1]].map({ $0.name }))")
            XCTAssertEqual(independent.count, 1)
            XCTAssertEqual(independent.first?.id.uuidString, landmarkNodes[2].name)
            didCallCustom.fulfill()
        })
        
        // When
        landmarker.interactiveScene(scene, hasIntersectingNodes: [[landmarkNodes[0], landmarkNodes[1]]], notIntersecting: [landmarkNodes[2]], atGeneration: 1)
        
        // Then
        wait(for: [didCallCustom], timeout: 1.0)
    }

}

class MockScene: InteractiveScene {
    
}

class MockLocationManager: CLLocationManager {
    
}

class MockARSKView: ARSKView {
    let mockSession = MockARSession()
    override var session: ARSession {
        get { return mockSession }
        set { return }
    }
    
    override func node(for anchor: ARAnchor) -> SKNode? {
        return mockSession.anchorNodes[anchor]
    }
    
    override func anchor(for node: SKNode) -> ARAnchor? {
        return mockSession.anchorNodes.first(where: { $0.value == node })?.key
    }
}

class MockARSession: ARSession {
    var anchors = [ARAnchor]()
    var anchorNodes: [ARAnchor: SKNode] = [:]

    override func add(anchor: ARAnchor) {
        super.add(anchor: anchor)
        anchors.append(anchor)
    }

    override func remove(anchor: ARAnchor) {
        super.remove(anchor: anchor)
        if let index = anchors.firstIndex(of: anchor) {
            anchors.remove(at: index)
        }
    }
}

class MockLandmarkerDelegate: ARLandmarkDisplayerDelegate {
    var tappedLandmark: ARLandmark?
    var error: Error?
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarkDisplayer, didTap landmark: ARLandmark) {
        tappedLandmark = landmark
    }
    
    func landmarkDisplayer(_ landmarkDisplayer: ARLandmarkDisplayer, didFailWithError error: Error) {
        self.error = error
    }
}
