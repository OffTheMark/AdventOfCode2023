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
    }
    
    func part1(grid: Grid) -> Int {
        let tilted = grid.tiltedNorth()
        
        return tilted.rocksByPoint.reduce(into: 0, { sum, element in
            let (point, rock) = element
            
            guard rock == .rounded else {
                return
            }
            
            sum += tilted.size.height - point.y
        })
    }
    
    struct Grid {
        typealias Rock = Day14.Rock
        
        let rocksByPoint: [Point2D: Rock]
        let size: Size2D
        
        var columns: Range<Int> { 0 ..< size.width }
        var rows: Range<Int> { 0 ..< size.height }
        
        let minX: Int = 0
        var maxX: Int { size.width - 1 }
        
        let minY: Int = 0
        var maxY: Int { size.height - 1 }
        
        func tiltedNorth() -> Self {
            var rocksByPoint = rocksByPoint
            
            for column in columns {
                let rocksInColumn = rocksByPoint.filter({ $0.key.x == column }).sorted(by: { $0.key.y < $1.key.y })
                var lastPlacedRock: (point: Point2D, rock: Rock)?
                
                for (point, rock) in rocksInColumn {
                    switch rock {
                    case .square:
                        lastPlacedRock = (point, rock)
                        
                    case .rounded:
                        let newPoint = if let lastPlacedRock {
                            Point2D(x: lastPlacedRock.point.x, y: lastPlacedRock.point.y + 1)
                        }
                        else {
                            Point2D(x: column, y: 0)
                        }
                        
                        if newPoint.y < point.y {
                            rocksByPoint.removeValue(forKey: point)
                            rocksByPoint[newPoint] = rock
                            lastPlacedRock = (newPoint, rock)
                        }
                        else {
                            lastPlacedRock = (point, rock)
                        }
                    }
                }
            }
            
            return Self(rocksByPoint: rocksByPoint, size: size)
        }
    }
    
    enum Rock: Character {
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
