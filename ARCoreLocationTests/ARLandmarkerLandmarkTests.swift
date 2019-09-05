//
//  ARLandmarkerLandmarkTests.swift
//  ARCoreLocationTests
//
//  Created by Skyler Smith on 2018-09-24.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import XCTest
import ARKit
import CoreLocation
@testable import ARCoreLocation

class ARLandmarkerLandmarkTests: XCTestCase {

    var landmarker: ARLandmarker!
    var locationManager: MockLocationManager!
    var scene: MockScene!
    var view: MockARSKView!
    
    var startLocation = CLLocation(latitude: 40.6892, longitude: -74.0445)
    
    override func setUp() {
        super.setUp()
        locationManager = MockLocationManager()
        scene = MockScene()
        view = MockARSKView()
        landmarker = ARLandmarker(view: view, scene: scene, locationManager: locationManager)
        landmarker.captureDeviceAuthorizer = MockCaptureDeviceAuthorizer.self
        landmarker.locationManager(locationManager, didUpdateLocations: [startLocation])
        let worldOriginSetPromise = expectation(description: "set world origin")
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.01) {
            worldOriginSetPromise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    override func tearDown() {
        locationManager = nil
        scene = nil
        landmarker = nil
        super.tearDown()
    }

    func testAddLandmarkImage() {
        // Given
        let location = CLLocation(latitude: 40.6755, longitude: -74.0521)
        let image = UIImage()
        var landmark: ARLandmark?
        
        // When
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { (arLandmark) in
            // Then
            landmark = arLandmark
            XCTAssertNotNil(arLandmark)
            XCTAssertEqual(arLandmark?.location, location)
            XCTAssertEqual(arLandmark?.image, image)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
        // Then
        XCTAssertTrue(landmarker.currentLandmarks.contains(where: { $0.id == landmark?.id }))
    }
    
    func testAddLandmarkView() {
        // Given
        let location = CLLocation(latitude: 40.7755, longitude: -74.0544)
        let labelRect = CGRect(x: 0, y: 0, width: 100, height: 17)
        let label = UILabel(frame: labelRect)
        label.text = "Test Add Landmark Label"
        var landmark: ARLandmark?
        
        // When
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(view: label, at: location) { (arLandmark) in
            // Then
            landmark = arLandmark
            XCTAssertNotNil(arLandmark)
            XCTAssertEqual(arLandmark?.location, location)
            XCTAssertEqual(arLandmark?.image.size, labelRect.size)
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
        // Then
        XCTAssertTrue(landmarker.currentLandmarks.contains(where: { $0.id == landmark?.id }))
    }
    
    func testRemoveLandmark() {
        // Given
        let location = CLLocation(latitude: 40, longitude: -74)
        let image = UIImage()
        var landmark: ARLandmark?
        
        let promise = expectation(description: "addLandmark")
        landmarker.addLandmark(image: image, at: location) { (arLandmark) in
            landmark = arLandmark
            promise.fulfill()
        }
        wait(for: [promise], timeout: 0.2)
        XCTAssertNotNil(landmark)
        
        // When
        let removed = landmarker.remove(landmark: landmark!)
        
        // Then
        XCTAssertTrue(removed)
        XCTAssertTrue(landmarker.currentLandmarks.isEmpty)
    }
    
    func testRemoveOneLandmark() {
        // Given
        let location1 = CLLocation(latitude: 35, longitude: 43)
        let image1 = UIImage()
        var landmark1: ARLandmark?
        
        let location2 = CLLocation(latitude: 35.002, longitude: 42.8987)
        let view2 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view2.text = "View 2"
        var landmark2: ARLandmark?
        
        let promise1 = expectation(description: "addLandmark1")
        landmarker.addLandmark(image: image1, at: location1) { (arLandmark) in
            landmark1 = arLandmark
            promise1.fulfill()
        }
        
        let promise2 = expectation(description: "addLandmark2")
        landmarker.addLandmark(view: view2, at: location2) { (arLandmark) in
            landmark2 = arLandmark
            promise2.fulfill()
        }
        wait(for: [promise1, promise2], timeout: 0.2)
        XCTAssertNotNil(landmark1)
        XCTAssertNotNil(landmark2)
        
        // When
        let removed = landmarker.remove(landmark: landmark1!)
        
        // Then
        XCTAssertTrue(removed)
        XCTAssertEqual(landmarker.currentLandmarks.count, 1)
        XCTAssertTrue(landmarker.currentLandmarks.contains(where: { $0.id == landmark2?.id }))
        XCTAssertFalse(landmarker.currentLandmarks.contains(where: { $0.id == landmark1?.id }))
    }
    
    func testFailToRemoveLandmark() {
        // Given
        let landmark = ARLandmark(userInfo: [:], image: UIImage(), location: CLLocation(latitude: 20, longitude: -54), id: UUID())
        
        // When
        let removed = landmarker.remove(landmark: landmark)
        
        // Then
        XCTAssertFalse(removed)
        XCTAssertTrue(landmarker.currentLandmarks.isEmpty)
    }
    
    func testRemoveAllLandmarks() {
        // Given
        let location1 = CLLocation(latitude: 35, longitude: 43)
        let image1 = UIImage()
        var landmark1: ARLandmark?
        
        let location2 = CLLocation(latitude: 35.002, longitude: 42.8987)
        let view2 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view2.text = "View 2"
        var landmark2: ARLandmark?
        
        let promise1 = expectation(description: "addLandmark1")
        landmarker.addLandmark(image: image1, at: location1) { (arLandmark) in
            landmark1 = arLandmark
            promise1.fulfill()
        }
        
        let promise2 = expectation(description: "addLandmark2")
        landmarker.addLandmark(view: view2, at: location2) { (arLandmark) in
            landmark2 = arLandmark
            promise2.fulfill()
        }
        wait(for: [promise1, promise2], timeout: 0.2)
        XCTAssertNotNil(landmark1)
        XCTAssertNotNil(landmark2)
        XCTAssertEqual(landmarker.currentLandmarks.count, 2)
        
        // When
        landmarker.removeAllLandmarks()
        
        // Then
        XCTAssertTrue(landmarker.currentLandmarks.isEmpty)
    }
    
}

struct MockCaptureDeviceAuthorizer: AVCaptureDeviceAuthorizer {
    static func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void) {
        handler(true)
    }
}
