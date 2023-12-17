//
//  Grid.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-17.
//

import Foundation

// MARK: Grid

struct Grid<Value> {
    let valuesByPosition: [Point2D: Value]
    let origin: Point2D
    let size: Size2D
    
    var columns: Range<Int> { origin.x ..< origin.x + size.width }
    var rows: Range<Int> { origin.y ..< origin.y + size.height }
    
    var minX: Int { origin.x }
    var miny: Int { origin.y }
    var maxX: Int { origin.x + size.width - 1 }
    var maxY: Int { origin.y + size.height - 1 }
    
    func contains(_ position: Point2D) -> Bool {
        valuesByPosition.keys.contains(position)
    }
}

extension Grid where Value: RawRepresentable, Value.RawValue == Character {
    init(rawValue: String) {
        let lines = rawValue.components(separatedBy: .newlines)
        
        var size = Size2D(width: 0, height: lines.count)
        let valuesByPosition: [Point2D: Value] = lines.enumerated().reduce(into: [:], { result, element in
            let (y, line) = element
            
            size.width = max(size.width, line.count)
            
            for (x, character) in line.enumerated() {
                guard let value = Value(rawValue: character) else {
                    continue
                }
                
                let position = Point2D(x: x, y: y)
                result[position] = value
            }
        })
        
        self.valuesByPosition = valuesByPosition
        self.origin = .zero
        self.size = size
    }
}

// MARK: - Point2D

struct Point2D: Hashable {
    var x: Int
    var y: Int
    
    func adjacentPoints(includingDiagonals includesDiagonals: Bool) -> Set<Point2D> {
        var translations: [Translation2D] = [
            .up,
            .right,
            .down,
            .left,
        ]
        if includesDiagonals {
            translations += [
                .upRight,
                .downRight,
                .downLeft,
                .upLeft,
            ]
        }
        
        return Set(translations.map({ applying($0) }))
    }
    
    mutating func apply(_ translation: Translation2D) {
        x += translation.deltaX
        y += translation.deltaY
    }
    
    func applying(_ translation: Translation2D) -> Self {
        var copy = self
        copy.apply(translation)
        return copy
    }
    
    static let zero = Self(x: 0, y: 0)
}

// MARK: - Translation2D

struct Translation2D: Hashable {
    var deltaX: Int
    var deltaY: Int
    
    static let up = Self(deltaX: 0, deltaY: -1)
    static let upRight = Self(deltaX: 1, deltaY: -1)
    static let right = Self(deltaX: 1, deltaY: 0)
    static let downRight = Self(deltaX: 1, deltaY: 1)
    static let down = Self(deltaX: 0, deltaY: 1)
    static let downLeft = Self(deltaX: -1, deltaY: 1)
    static let left = Self(deltaX: -1, deltaY: 0)
    static let upLeft = Self(deltaX: -1, deltaY: -1)
}
