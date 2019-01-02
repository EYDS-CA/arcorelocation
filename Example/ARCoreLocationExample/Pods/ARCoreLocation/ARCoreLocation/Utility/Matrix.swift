//
//  Matrix.swift
//  ARCoreLocation
//
//  Created by Skyler Smith on 2018-09-21.
//  Copyright © 2018 Skyler Smith. All rights reserved.
//

import GLKit
import CoreLocation

// Convenience object for performing matrix math
struct Matrix {
    static func convert(glkMatrix matrix: GLKMatrix4) -> float4x4 {
        return float4x4(float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
                        float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
                        float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
                        float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
    }
    
    /// - parameter radians: Angle relative to 'foward-looking' X axis, with right being the positive direction
    static func rotateHorizontally(matrix: simd_float4x4, around radians: Float) -> simd_float4x4 {
        let rotation = GLKMatrix4MakeYRotation(radians)
        return simd_mul(convert(glkMatrix: rotation), matrix)
    }
    
    /// - parameter radians: Angle relative to 'foward-looking' Y axis, with down being the positive direction
    static func rotateVertically(matrix: simd_float4x4, around radians: Float) -> simd_float4x4 {
        let rotation = GLKMatrix4MakeXRotation(radians)
        return simd_mul(convert(glkMatrix: rotation), matrix)
    }
    
    /// - returns: The angle, in radians, from the start location to the end location
    static func angle(from start: CLLocation, to end: CLLocation) -> Float {
        let startLat = GLKMathDegreesToRadians(Float(start.coordinate.latitude))
        let startLon = GLKMathDegreesToRadians(Float(start.coordinate.longitude))
        let endLat = GLKMathDegreesToRadians(Float(end.coordinate.latitude))
        let endLon = GLKMathDegreesToRadians(Float(end.coordinate.longitude))
        
        let lonDiff = endLon - startLon
        let y = sin(lonDiff) * cos(endLat)
        let x = (cos(startLat) * sin(endLat)) - (sin(startLat) * cos(endLat) * cos(lonDiff))
        var angle = atan2(y, x)
        if angle < 0 { angle += Float.pi * 2 } // Angle should not be less than -2π, so just adjusting it up once should be sufficient.
        return angle
    }
    
    static func angleOffHorizon(from start: CLLocation, to end: CLLocation) -> Float {
        let adjacent = start.distance(from: end)
        let opposite = end.altitude - start.altitude
        return Float(atan2(opposite, adjacent))
    }
}

extension simd_float4x4 {
    static func translatingIdentity(x: Float, y: Float, z: Float) -> simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.3.x = x
        result.columns.3.y = y
        result.columns.3.z = z
        return result
    }
}
