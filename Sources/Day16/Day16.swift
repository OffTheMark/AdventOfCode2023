//
//  Day16.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-16.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections

struct Day16: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day16",
            abstract: "Solve day 16 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid(rawValue: try readFile())
        
        printTitle("Part 1", level: .title1)
        let numberOfEnergizedTiles = part1(grid: grid)
        print("Number of energized tiles:", numberOfEnergizedTiles, terminator: "\n\n")
    }
    
    func part1(grid: Grid) -> Int {
        var energizedTiles = Set<Point2D>()
        
        let start = Beam(position: .zero, direction: .right)
        var visited = Set<Beam>()
        var stack: Deque<Beam> = [start]
        
        while let beam = stack.popLast() {
            visited.insert(beam)
            energizedTiles.insert(beam.position)
            
            for neighbor in grid.neighbors(for: beam) where !visited.contains(neighbor) {
                stack.append(neighbor)
            }
        }
        
        return energizedTiles.count
    }
    
    enum Mirror: Character {
        case vertical = "|"
        case horizontal = "-"
        case leftLeaningDiagonal = "\\"
        case rightLeaningDiagonal = "/"
        
        func resultingDirections(for direction: Direction) -> [Direction] {
            switch (self, direction) {
            case (.vertical, .up),
                 (.vertical, .down):
                return [direction]
                
            case (.vertical, .left), 
                 (.vertical, .right):
                return [.up, .down]
                
            case (.horizontal, .up),
                 (.horizontal, .down):
                return [.left, .right]
                
            case (.horizontal, .left),
                 (.horizontal, .right):
                return [direction]
                
            case (.leftLeaningDiagonal, .up):
                return [.left]
                
            case (.leftLeaningDiagonal, .down):
                return [.right]
                
            case (.leftLeaningDiagonal, .left):
                return [.up]
                
            case (.leftLeaningDiagonal, .right):
                return [.down]
                
            case (.rightLeaningDiagonal, .up):
                return [.right]
                
            case (.rightLeaningDiagonal, .down):
                return [.left]
                
            case (.rightLeaningDiagonal, .left):
                return [.down]
                
            case (.rightLeaningDiagonal, .right):
                return [.up]
            }
        }
        
    }
    
    enum Direction: Hashable {
        case up
        case right
        case down
        case left
        
        var translation: Translation2D {
            switch self {
            case .up:
                Translation2D(deltaX: 0, deltaY: -1)
            
            case .right:
                Translation2D(deltaX: 1, deltaY: 0)
                
            case .down:
                Translation2D(deltaX: 0, deltaY: 1)
                
            case .left:
                Translation2D(deltaX: -1, deltaY: 0)
            }
        }
    }
    
    struct Grid {
        typealias Mirror = Day16.Mirror
        
        let mirrorsByPoint: [Point2D: Mirror]
        let size: Size2D
        
        func contains(_ point: Point2D) -> Bool {
            (0 ..< size.width).contains(point.x) && (0 ..< size.height).contains(point.y)
        }
        
        func neighbors(for beam: Beam) -> [Beam] {
            guard let mirror = mirrorsByPoint[beam.position] else {
                var result = beam
                result.position = result.position.applying(beam.direction.translation)
                
                return [result].filter({ contains($0.position) })
            }
            
            let directions = mirror.resultingDirections(for: beam.direction)
            return directions.compactMap({ direction in
                let result = Beam(
                    position: beam.position.applying(direction.translation),
                    direction: direction
                )
                
                guard contains(result.position) else {
                    return nil
                }
                
                return result
            })
        }
    }
    
    struct Beam: Hashable {
        var position: Point2D
        var direction: Direction
    }
}

extension Day16.Grid {
    init(rawValue: String) {
        let lines = rawValue.components(separatedBy: .newlines)
        
        var mirrorsByPoint = [Point2D: Mirror]()
        var size = Size2D(width: 0, height: lines.count)
        
        for (y, line) in lines.enumerated() {
            size.width = max(size.width, line.count)
            
            for (x, character) in line.enumerated() {
                guard let mirror = Mirror(rawValue: character) else {
                    continue
                }
                
                let point = Point2D(x: x, y: y)
                mirrorsByPoint[point] = mirror
            }
        }
        
        self.mirrorsByPoint = mirrorsByPoint
        self.size = size
    }
}
