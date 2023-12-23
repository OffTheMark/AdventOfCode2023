//
//  Point3D.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-22.
//

import Foundation

struct Point3D: Hashable {
    var x: Int
    var y: Int
    var z: Int
    
    mutating func apply(_ translation: Translation3D) {
        x += translation.deltaX
        y += translation.deltaY
        z += translation.deltaZ
    }
    
    func applying(_ translation: Translation3D) -> Self {
        var result = self
        result.apply(translation)
        return result
    }
}

struct Translation3D: Hashable {
    var deltaX: Int
    var deltaY: Int
    var deltaZ: Int
    
    static func * (lhs: Self, rhs: Int) -> Self {
        Self(deltaX: lhs.deltaX * rhs, deltaY: lhs.deltaY * rhs, deltaZ: lhs.deltaZ * rhs)
    }
}
