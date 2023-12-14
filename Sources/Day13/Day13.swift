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
        let grids = try readFile().components(separatedBy: "\n\n").map({ block in
            let rows = block.components(separatedBy: .newlines)
            return Grid(rows: rows)
        })
        
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
        let rows: [String]
        let columns: [String]
        
        init(rows: [String]) {
            var columns = [String]()
            
            for row in rows {
                for (x, character) in row.enumerated() {
                    if !columns.indices.contains(x) {
                        columns.append("")
                    }
                    
                    columns[x].append(character)
                }
            }
            
            self.rows = rows
            self.columns = columns
        }
        
        func horizontalReflectionLine() -> Int? {
            let numberOfColumns = columns.count
            return columns.indices.dropLast().first(where: { index in
                let distances = 0 ... min(index, numberOfColumns - index - 2)
                
                return distances.allSatisfy({ distance in
                    let leftColumnIndex = index - distance
                    let rightColumnIndex = index + distance + 1
                    let leftColumn = columns[leftColumnIndex]
                    let rightColumn = columns[rightColumnIndex]
                    
                    return leftColumn == rightColumn
                })
            })
        }
        
        func verticalReflectionLine() -> Int? {
            let numberOfRows = rows.count
            return rows.indices.dropLast().first(where: { index in
                let distances = 0 ... min(index, numberOfRows - index - 2)
                
                return distances.allSatisfy({ distance in
                    let topRowIndex = index - distance
                    let bottomRowIndex = index + distance + 1
                    let topRow = rows[topRowIndex]
                    let bottomRow = rows[bottomRowIndex]
                    
                    return topRow == bottomRow
                })
            })
        }
    }
}

