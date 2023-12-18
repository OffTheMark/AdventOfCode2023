//
//  Day11.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-11.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser
import Collections

struct Day11: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day11",
            abstract: "Solve day 11 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (galaxies, emptySpace) = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let sumOfShortestPaths = part1(galaxies: galaxies, emptySpace: emptySpace)
        print("Sum of the shortest path between every pair of galaxies:", sumOfShortestPaths, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfShortestPathsWhenExpanded = part2(galaxies: galaxies, emptySpace: emptySpace)
        print("Sum of the shortest path between every pair of galaxies:", sumOfShortestPathsWhenExpanded)
    }
    
    private func parse(_ lines: [String]) -> (galaxies: Set<Point2D>, emptySpace: EmptySpace) {
        var size = Size2D(width: 0, height: lines.count)
        var occupiedXCoordinates = Set<Int>()
        var occupiedYCoordinates = Set<Int>()
        
        let galaxies = lines.enumerated().reduce(into: Set<Point2D>(), { result, pair in
            let (y, line) = pair
            
            size.width = max(size.width, line.count)
            
            for (x, character) in line.enumerated() {
                guard character == "#" else {
                    continue
                }
                
                occupiedXCoordinates.insert(x)
                occupiedYCoordinates.insert(y)
                
                let point = Point2D(x: x, y: y)
                result.insert(point)
            }
        })
        let emptySpace = EmptySpace(
            xCoordinates: Set(0 ..< size.width).subtracting(occupiedXCoordinates),
            yCoordinates: Set(0 ..< size.height).subtracting(occupiedYCoordinates)
        )
        
        return (galaxies, emptySpace)
    }
    
    func part1(galaxies: Set<Point2D>, emptySpace: EmptySpace) -> Int {
        let combinations = galaxies.combinations(ofCount: 2)
        let distanceOfEmptySpace = 2
        
        return combinations.reduce(into: 0, { sum, combination in
            let start = combination[0]
            let end = combination[1]
            
            let distance = distance(
                from: start,
                to: end,
                emptySpace: emptySpace,
                distanceOfEmptySpace: distanceOfEmptySpace
            )
            sum += distance
        })
    }
    
    func part2(galaxies: Set<Point2D>, emptySpace: EmptySpace) -> Int {
        let combinations = galaxies.combinations(ofCount: 2)
        let distanceOfEmptySpace = 1_000_000
        
        return combinations.reduce(into: 0, { sum, combination in
            let start = combination[0]
            let end = combination[1]
            
            let distance = distance(
                from: start,
                to: end,
                emptySpace: emptySpace,
                distanceOfEmptySpace: distanceOfEmptySpace
            )
            sum += distance
        })
    }
    
    func distance(
        from start: Point2D,
        to end: Point2D,
        emptySpace: EmptySpace,
        distanceOfEmptySpace: Int)
    -> Int {
        let xCoordinates = min(start.x, end.x) ... max(start.x, end.x)
        let yCoordinates = min(start.y, end.y) ... max(start.y, end.y)
        
        let xDistance = xCoordinates.dropFirst().reduce(0, { distance, x in
            if emptySpace.xCoordinates.contains(x) {
                distance + distanceOfEmptySpace
            }
            else {
                distance + 1
            }
        })
        let yDistance = yCoordinates.dropFirst().reduce(0, { distance, y in
            if emptySpace.yCoordinates.contains(y) {
                distance + distanceOfEmptySpace
            }
            else {
                distance + 1
            }
        })
        return xDistance + yDistance
    }
    
    struct EmptySpace {
        let xCoordinates: Set<Int>
        let yCoordinates: Set<Int>
    }
}
