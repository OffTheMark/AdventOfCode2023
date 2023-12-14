//
//  Day13.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-13.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser

struct Day13: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day13",
            abstract: "Solve day 13 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grids = try readFile().components(separatedBy: "\n\n").map(Grid.init)
        
        printTitle("Part 1", level: .title1)
        let sumOfNotes = part1(grids: grids)
        print("Sum of all notes:", sumOfNotes, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfNotesAfterCorrectingSmudges = part2(grids: grids)
        print("Summ of all notes after correcting smudges:", sumOfNotesAfterCorrectingSmudges)
    }
    
    func part1(grids: [Grid]) -> Int {
        grids.reduce(into: 0, { sum, grid in
            if let firstReflectionLine = grid.firstReflectionLine() {
                switch firstReflectionLine {
                case .horizontal(let column):
                    sum += column
                    
                case .vertical(let row):
                    sum += row * 100
                }
            }
        })
    }
    
    func part2(grids: [Grid]) -> Int {
        grids.reduce(into: 0, { sum, grid in
            let firstReflectionLine = grid.firstReflectionLine()!
            
            var reflectionLine: ReflectionLine?
            for point in product(grid.columns, grid.rows).lazy.map(Point2D.init) {
                let corrected = grid.togglingState(at: point)
                let reflectionLinesExceptExistingOne = corrected.reflectionLines().subtracting([firstReflectionLine])
                
                if reflectionLinesExceptExistingOne.count == 1 {
                    reflectionLine = reflectionLinesExceptExistingOne.first
                    break
                }
            }
            
            guard let reflectionLine else {
                return
            }
            
            switch reflectionLine {
            case .horizontal(let column):
                sum += column
                
            case .vertical(let row):
                sum += row * 100
            }
        })
    }
    
    struct Grid {
        typealias State = Day13.State
        
        let statesByPoint: [Point2D: State]
        let width: Int
        let height: Int
        
        var columns: Range<Int> { 0 ..< width }
        var rows: Range<Int> { 0 ..< height }
        
        func togglingState(at point: Point2D) -> Self {
            var statesByPoint = statesByPoint
            statesByPoint[point]?.toggle()
            
            return Self(statesByPoint: statesByPoint, width: width, height: height)
        }
        
        func firstReflectionLine() -> ReflectionLine? {
            if let verticalLine = firstVerticalReflectionLine() {
                return .vertical(verticalLine)
            }
            
            return firstHorizontalReflectionLine().map({ .horizontal($0) })
        }
        
        func firstVerticalReflectionLine() -> Int? {
            rows.dropFirst().first(where: isRowReflectionLine)
        }
        
        func firstHorizontalReflectionLine() -> Int? {
            columns.dropFirst().first(where: isColumnReflectionLine)
        }
        
        func reflectionLines() -> Set<ReflectionLine> {
            let verticalReflectionLines = verticalReflectionLines()
            let horizontalReflectionLines = horizontalReflectionLines()
            
            return Set(
                verticalReflectionLines.map({ .vertical($0) }) + 
                horizontalReflectionLines.map({ .horizontal($0) })
            )
        }
        
        func verticalReflectionLines() -> [Int] {
            rows.dropFirst().filter(isRowReflectionLine)
        }
        
        func horizontalReflectionLines() -> [Int] {
            columns.dropFirst().filter(isColumnReflectionLine)
        }
        
        private func isColumnReflectionLine(_ column: Int) -> Bool {
            let distances = 0 ... min(column - 1, width - column - 1)
            
            return distances.allSatisfy({ distance in
                let leftColumn = column - distance - 1
                let rightColumn = column + distance
                
                return rows.allSatisfy({ row in
                    let leftPoint = Point2D(x: leftColumn, y: row)
                    let rightPoint = Point2D(x: rightColumn, y: row)
                    
                    return statesByPoint[leftPoint] == statesByPoint[rightPoint]
                })
            })
        }
        
        private func isRowReflectionLine(_ row: Int) -> Bool {
            let distances = 0 ... min(row - 1, height - row - 1)
            
            return distances.allSatisfy({ distance in
                let topRow = row - distance - 1
                let bottomRow = row + distance
                
                return columns.allSatisfy({ column in
                    let topPoint = Point2D(x: column, y: topRow)
                    let bottomPoint = Point2D(x: column, y: bottomRow)
                    
                    return statesByPoint[topPoint] == statesByPoint[bottomPoint]
                })
            })
        }
    }
    
    enum State: Character {
        case ash = "."
        case rock = "#"
        
        mutating func toggle() {
            switch self {
            case .ash:
                self = .rock
                
            case .rock:
                self = .ash
            }
        }
    }
    
    enum ReflectionLine: Hashable {
        case horizontal(Int)
        case vertical(Int)
    }
}

extension Day13.Grid {
    init(rawValue: String) {
        let rows = rawValue.components(separatedBy: .newlines)
        let height = rows.count
        var width = 0
        var statesByPoint = [Point2D: State]()
        
        for (y, row) in rows.enumerated() {
            width = max(width, row.count)
            
            for (x, character) in row.enumerated() {
                
                guard let state = State(rawValue: character) else {
                    continue
                }
                
                let point = Point2D(x: x, y: y)
                statesByPoint[point] = state
            }
        }
        
        self.statesByPoint = statesByPoint
        self.width = width
        self.height = height
    }
}
