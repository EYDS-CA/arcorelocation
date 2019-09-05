//
//  MatrixTests.swift
//  ARCoreLocationTests
//
//  Created by Skyler Smith on 2018-09-24.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import XCTest
import CoreLocation
import GLKit
@testable import ARCoreLocation

class MatrixTests: XCTestCase {

    func testAngle1() {
        // Given
        let start = CLLocation(latitude: 0, longitude: 0)
        let end = CLLocation(latitude: 10, longitude: 0)
        
        // When
        let angle = Matrix.angle(from: start, to: end)
        
        // Then
        XCTAssertEqual(angle, GLKMathDegreesToRadians(0), accuracy: 0.01)
    }
    
    func testAngle2() {
        // Given
        let start = CLLocation(latitude: 0, longitude: 0)
        let end = CLLocation(latitude: 10, longitude: 10)
        
        // When
        let angle = Matrix.angle(from: start, to: end)
        
        // Then
        XCTAssertEqual(angle, GLKMathDegreesToRadians(44.561), accuracy: 0.01)
    }
    
    func testAngle3() {
        // Given
        let start = CLLocation(latitude: 49.37963, longitude: -123.08347)
        let end = CLLocation(latitude: 49.37937, longitude: -123.08137)
        
        // When
        let angle = Matrix.angle(from: start, to: end)
        
        // Then
        XCTAssertEqual(angle, GLKMathDegreesToRadians(100.767), accuracy: 0.01)
    }
    
    func testAngleOffHorizon1() {
        //Given
        let start = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), altitude: 0, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        let end = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.05, longitude: 0), altitude: 20, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date())
        
        // When
        let angle = Matrix.angleOffHorizon(from: start, to: end)
        
        // Then
        XCTAssertEqual(angle, 0.003617, accuracy: 0.000001)
    }

}
