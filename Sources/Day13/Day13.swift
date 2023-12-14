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
    }
    
    func part1(grids: [Grid]) -> Int {
        grids.reduce(into: 0, { sum, grid in
            if let horizontalReflectionLine = grid.horizontalReflectionLine() {
                sum += horizontalReflectionLine + 1
            }
            
            if let verticalReflectionLine = grid.verticalReflectionLine() {
                sum += 100 * (verticalReflectionLine + 1)
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
        
        func horizontalReflectionLine() -> Int? {
            columns.dropLast().first(where: { column in
                let distances = 0 ... min(column, width - column - 2)
                
                return distances.allSatisfy({ distance in
                    let leftColumn = column - distance
                    let rightColumn = column + distance + 1
                    
                    return rows.allSatisfy({ row in
                        let leftPoint = Point2D(x: leftColumn, y: row)
                        let rightPoint = Point2D(x: rightColumn, y: row)
                        
                        return statesByPoint[leftPoint] == statesByPoint[rightPoint]
                    })
                })
            })
        }
        
        func verticalReflectionLine() -> Int? {
            rows.dropLast().first(where: { row in
                let distances = 0 ... min(row, height - row - 2)
                
                return distances.allSatisfy({ distance in
                    let topRow = row - distance
                    let bottomRow = row + distance + 1
                    
                    return columns.allSatisfy({ column in
                        let topPoint = Point2D(x: column, y: topRow)
                        let bottomPoint = Point2D(x: column, y: bottomRow)
                        
                        return statesByPoint[topPoint] == statesByPoint[bottomPoint]
                    })
                })
            })
        }
    }
    
    enum State: Character {
        case ash = "."
        case rock = "#"
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
