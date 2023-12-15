//
//  Day14.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-14.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser

struct Day14: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day14",
            abstract: "Solve day 14 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid(rawValue: try readFile())
        
        printTitle("Part 1", level: .title1)
        let totalLoadOnNorthSupportBeams = part1(grid: grid)
        print("Total load on the north support beams:", totalLoadOnNorthSupportBeams, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let totalLoadAfterSpinCycles = part2(grid: grid)
        print("Total load on the north support beams after 1,000,000,000 spin cycles:", totalLoadAfterSpinCycles)
    }
    
    func part1(grid: Grid) -> Int {
        let tilted = grid.tiltedNorth()
        
        return tilted.loadOnNorthSupportBeams()
    }
    
    func part2(grid: Grid) -> Int {
        let spinCycles = 1_000_000_000
        
        var grid = grid
        var spinCyclesByGrid = [Grid: Int]()
        var currentCycle = 0
        var hasJumped = false
        
        while currentCycle < spinCycles {
            grid = grid.tiltedNorth()
            grid = grid.tiltedWest()
            grid = grid.tiltedSouth()
            grid = grid.tiltedEast()
            
            if !hasJumped, let previousSpinCycle = spinCyclesByGrid[grid] {
                let cycleSize = currentCycle - previousSpinCycle
                
                let numberOfPossibleJumps = (spinCycles - currentCycle) / cycleSize
                let jump = numberOfPossibleJumps * cycleSize + 1
                currentCycle += jump
                hasJumped = true
            }
            else {
                spinCyclesByGrid[grid] = currentCycle
                currentCycle += 1
            }
        }
        
        return grid.loadOnNorthSupportBeams()
    }
    
    struct Grid: Hashable {
        typealias Rock = Day14.Rock
        
        let rocksByPoint: [Point2D: Rock]
        let size: Size2D
        
        var columns: Range<Int> { 0 ..< size.width }
        var rows: Range<Int> { 0 ..< size.height }
        
        let minX: Int = 0
        var maxX: Int { size.width - 1 }
        
        let minY: Int = 0
        var maxY: Int { size.height - 1 }
        
        var description: String {
            rows.map({ y -> String in
                String(columns.map({ x -> Character in
                    let point = Point2D(x: x, y: y)
                    
                    return rocksByPoint[point]?.rawValue ?? "."
                }))
            }).joined(separator: "\n")
        }
        
        func loadOnNorthSupportBeams() -> Int {
            rocksByPoint.reduce(into: 0, { sum, element in
                let (point, rock) = element
                
                guard rock == .rounded else {
                    return
                }
                
                sum += size.height - point.y
            })
        }
        
        func tiltedNorth() -> Self {
            var rocksByPoint = rocksByPoint
            
            for column in columns {
                let rocksInColumn = rocksByPoint.filter({ $0.key.x == column }).sorted(by: { $0.key.y < $1.key.y })
                var lastPlacedPoint: Point2D?
                
                for (point, rock) in rocksInColumn {
                    switch rock {
                    case .square:
                        lastPlacedPoint = point
                        
                    case .rounded:
                        let newPoint = if let lastPlacedPoint {
                            Point2D(x: lastPlacedPoint.x, y: lastPlacedPoint.y + 1)
                        }
                        else {
                            Point2D(x: column, y: minY)
                        }
                        
                        if newPoint.y < point.y {
                            rocksByPoint.removeValue(forKey: point)
                            rocksByPoint[newPoint] = rock
                            lastPlacedPoint = newPoint
                        }
                        else {
                            lastPlacedPoint = point
                        }
                    }
                }
            }
            
            return Self(rocksByPoint: rocksByPoint, size: size)
        }
        
        func tiltedSouth() -> Self {
            var rocksByPoint = rocksByPoint
            
            for column in columns {
                let rocksInColumn = rocksByPoint.filter({ $0.key.x == column }).sorted(by: { $0.key.y > $1.key.y })
                var lastPlacedPoint: Point2D?
                
                for (point, rock) in rocksInColumn {
                    switch rock {
                    case .square:
                        lastPlacedPoint = point
                        
                    case .rounded:
                        let newPoint = if let lastPlacedPoint {
                            Point2D(x: lastPlacedPoint.x, y: lastPlacedPoint.y - 1)
                        }
                        else {
                            Point2D(x: column, y: maxY)
                        }
                        
                        if newPoint.y > point.y {
                            rocksByPoint.removeValue(forKey: point)
                            rocksByPoint[newPoint] = rock
                            lastPlacedPoint = newPoint
                        }
                        else {
                            lastPlacedPoint = point
                        }
                    }
                }
            }
            
            return Self(rocksByPoint: rocksByPoint, size: size)
        }
        
        func tiltedWest() -> Self {
            var rocksByPoint = rocksByPoint
            
            for row in rows {
                let rocksInRow = rocksByPoint.filter({ $0.key.y == row }).sorted(by: { $0.key.x < $1.key.x })
                var lastPlacedPoint: Point2D?
                
                for (point, rock) in rocksInRow {
                    switch rock {
                    case .square:
                        lastPlacedPoint = point
                        
                    case .rounded:
                        let newPoint = if let lastPlacedPoint {
                            Point2D(x: lastPlacedPoint.x + 1, y: lastPlacedPoint.y)
                        }
                        else {
                            Point2D(x: minX, y: row)
                        }
                        
                        if newPoint.x < point.x {
                            rocksByPoint.removeValue(forKey: point)
                            rocksByPoint[newPoint] = rock
                            lastPlacedPoint = newPoint
                        }
                        else {
                            lastPlacedPoint = point
                        }
                    }
                }
            }
            
            return Self(rocksByPoint: rocksByPoint, size: size)
        }
        
        func tiltedEast() -> Self {
            var rocksByPoint = rocksByPoint
            
            for row in rows {
                let rocksInRow = rocksByPoint.filter({ $0.key.y == row }).sorted(by: { $0.key.x > $1.key.x })
                var lastPlacedPoint: Point2D?
                
                for (point, rock) in rocksInRow {
                    switch rock {
                    case .square:
                        lastPlacedPoint = point
                        
                    case .rounded:
                        let newPoint = if let lastPlacedPoint {
                            Point2D(x: lastPlacedPoint.x - 1, y: lastPlacedPoint.y)
                        }
                        else {
                            Point2D(x: maxX, y: row)
                        }
                        
                        if newPoint.x > point.x {
                            rocksByPoint.removeValue(forKey: point)
                            rocksByPoint[newPoint] = rock
                            lastPlacedPoint = newPoint
                        }
                        else {
                            lastPlacedPoint = point
                        }
                    }
                }
            }
            
            return Self(rocksByPoint: rocksByPoint, size: size)
        }
    }
    
    enum Rock: Character, Hashable {
        case rounded = "O"
        case square = "#"
    }
}

extension Day14.Grid {
    init(rawValue: String) {
        let rows = rawValue.components(separatedBy: .newlines)
        
        var size = Size2D(width: 0, height: rows.count)
        
        let rocksByPoint: [Point2D: Rock] = rows.enumerated().reduce(into: [:], { result, pair in
            let (y, row) = pair
            
            size.width = max(size.width, row.count)
            
            for (x, character) in row.enumerated() {
                guard let rock = Rock(rawValue: character) else {
                    continue
                }
                
                let point = Point2D(x: x, y: y)
                result[point] = rock
            }
        })
        
        self.rocksByPoint = rocksByPoint
        self.size = size
    }
}
