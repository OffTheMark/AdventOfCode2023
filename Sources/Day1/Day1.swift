//
//  Day1.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-11-29.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day1: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day1",
                abstract: "Solve day 1 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let lines = try readLines()
            
            printTitle("Part 1", level: .title1)
            let sumOfCalibrationValues = part1(inputs: lines)
            print("Sum of calibration values:", sumOfCalibrationValues, terminator: "\n\n")
            
            printTitle("Part 2", level: .title1)
            let sumOfSecondCalibrationValues = part2(inputs: lines)
            print("Sum of calibration values:", sumOfSecondCalibrationValues)
        }
        
        func part1(inputs: [String]) -> Int {
            let calibrationValues: [Int] = inputs.map({ input in
                let digits = input.compactMap({ Int(String($0)) })
                
                if digits.isEmpty {
                    return 0
                }
                
                return digits.first! * 10 + digits.last!
            })
            
            return calibrationValues.reduce(0, +)
        }
        
        func part2(inputs: [String]) -> Int {
            let digitsByText: [String: Int] = [
                "1": 1,
                "2": 2,
                "3": 3,
                "4": 4,
                "5": 5,
                "6": 6,
                "7": 7,
                "8": 8,
                "9": 9,
                "one": 1,
                "two": 2,
                "three": 3,
                "four": 4,
                "five": 5,
                "six": 6,
                "seven": 7,
                "eight": 8,
                "nine": 9,
            ]
            
            func digits(in input: String) -> [Int] {
                var result = [Int]()
                var index = input.startIndex
                
                while index < input.endIndex {
                    let distanceFromStartIndex = input.distance(from: input.startIndex, to: index)
                    
                    let matchedDigit = digitsByText.first(where: { key, _ in
                        if distanceFromStartIndex + key.count > input.count {
                            return false
                        }
                        
                        let substring = input[index ..< input.index(index, offsetBy: key.count)]
                        return String(substring) == key
                    })
                    
                    if let matchedDigit {
                        result.append(matchedDigit.value)
                    }
                    
                    input.formIndex(&index, offsetBy: 1)
                }
                
                return result
            }
            
            let calibrationValues: [Int] = inputs.map({ input in
                let digits = digits(in: input)
                
                if digits.isEmpty {
                    return 0
                }
                
                return digits.first! * 10 + digits.last!
            })
            return calibrationValues.reduce(0, +)
        }
    }
}
