//
//  Vector3.swift
//  AppleAllegiance
//
//  Created by Kyle Peterson on 11/10/24.
//

import Foundation

struct Vector3: Codable {
    var x: Float
    var y: Float
    var z: Float
    
    /// Adds two vectors.
    static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x + rhs.x,
                      y: lhs.y + rhs.y,
                      z: lhs.z + rhs.z)
    }
    
    /// Multiplies a vector by a scalar.
    static func * (lhs: Float, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs * rhs.x,
                      y: lhs * rhs.y,
                      z: lhs * rhs.z)
    }
}
