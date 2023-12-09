//
//  Day9.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-08.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser

struct Day9: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day9",
            abstract: "Solve day 9 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let sequences = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let sumOfForwardExtrapolatedValues = part1(sequences: sequences)
        print(
            "What is the sum of extrapolated values (extrapolating forwards)?",
            sumOfForwardExtrapolatedValues,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let sumOfBackwardExtrapolatedValues = part2(sequences: sequences)
        print("What is the sum of extrapolated values (extrapolating backwards)?", sumOfBackwardExtrapolatedValues)
    }
    
    func part1(sequences: [[Int]]) -> Int {
        sequences.reduce(into: 0, { sum, sequence in
            let extrapolated = extrapolateForwards(sequence)
            sum += extrapolated
        })
    }
    
    func part2(sequences: [[Int]]) -> Int {
        sequences.reduce(into: 0, { sum, sequence in
            let extrapolated = extrapolateBackwards(sequence)
            sum += extrapolated
        })
    }
    
    private func extrapolateForwards(_ sequence: [Int]) -> Int {
        var lastValues = [sequence.last!]
        var current = sequence
        
        while !current.allSatisfy({ $0 == 0 }) {
            let nextCurrent = current.adjacentPairs().map({ (left, right) in
                right - left
            })
            
            nextCurrent.last.map({ lastValues.append($0) })
            current = nextCurrent
        }
        
        return lastValues.reduce(0, +)
    }
    
    private func extrapolateBackwards(_ sequence: [Int]) -> Int {
        var firstValues = [sequence.first!]
        var current = sequence
        
        while !current.allSatisfy({ $0 == 0 }) {
            let nextCurrent = current.adjacentPairs().map({ (left, right) in
                right - left
            })
            
            nextCurrent.first.map({ firstValues.append($0) })
            current = nextCurrent
        }
        
        var currentResult = firstValues
        while currentResult.count > 1 {
            let last = currentResult.removeLast()
            var replacedValue = currentResult.removeLast()
            replacedValue -= last
            currentResult.append(replacedValue)
        }
        
        return currentResult.first!
    }
    
    private func parse(_ lines: [String]) -> [[Int]] {
        lines.map({ line in
            line.components(separatedBy: " ").compactMap(Int.init)
        })
    }
}
