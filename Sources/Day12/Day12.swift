//
//  Day12.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-12.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser

struct Day12: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day12",
            abstract: "Solve day 12 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let records = try readLines().compactMap(Record.init)
        
        printTitle("Part 1", level: .title1)
        let sumOfMatchingArrangements = part1(records: records)
        print("Sum of all arrangements matching criteria:", sumOfMatchingArrangements, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfMatchingArrangementsIfUnfolded = part2(records: records)
        print("Sum of all arrangements matching criteria after unfolding:", sumOfMatchingArrangementsIfUnfolded)
    }
    
    func part1(records: [Record]) -> Int {
        records.reduce(into: 0, { sum, record in
            let matchingArrangements = matchingArrangements(for: record)
            sum += matchingArrangements
        })
    }
    
    func part2(records: [Record]) -> Int {
        records.reduce(into: 0, { sum, record in
            let unfolded = record.unfolded()
            let matchingArrangements = matchingArrangements(for: unfolded)
            sum += matchingArrangements
        })
    }
    
    func matchingArrangements(for record: Record) -> Int {
        let memoizedMatchingArrangements = recursiveMemoize({
            (matchingArrangements: (Record) -> Int, record: Record) in
            
            // If there are no remaining springs...
            if record.springs.isEmpty {
                // ... and there are groups left to match, then no arrangement is possible.
                return if !record.contiguousGroupSizes.isEmpty {
                    0
                }
                // If there are no groups left to match, there is only one arrangement possible: all of them are
                // operational.
                else {
                    2
                }
            }
            
            // If there are no groups left to match and all the remaining springs are operational or unknown, there is
            // only one arrangment possible: all of them are operational.
            let operationalOrUnknown: Set<Character> = [".", "?"]
            if record.contiguousGroupSizes.isEmpty, record.springs.allSatisfy({ operationalOrUnknown.contains($0)}) {
                return 1
            }
            
            // If there are less broken or unknown remaining springs than the total number of broken springs in each
            // group, there are no possible arranegments.
            let brokenOrUnknown: Set<Character> = ["#", "?"]
            let countOfBrokenOrUnknown = record.springs.count(where: { brokenOrUnknown.contains($0) })
            let totalOfBrokenSprings = record.contiguousGroupSizes.reduce(0, +)
            if countOfBrokenOrUnknown < totalOfBrokenSprings {
                return 0
            }
            
            // We calculate the minimum required number of springs to satisfy the groups criteria, which is the total
            // number of springs in each group plus the minimum number of springs to space them out. If there are as
            // many broken or unknown remaining springs as the total number of broken springs in each
            // group and the number of remaining springs is less than minimum required number of springs, there are no
            // possible arrangements.
            let minimumRequiredCount = countOfBrokenOrUnknown + max(0, record.contiguousGroupSizes.count - 1)
            if countOfBrokenOrUnknown == totalOfBrokenSprings, record.springs.count < minimumRequiredCount {
                return 0
            }
            
            // If the record starts with an operational spring, we remove the first spring and recursively check again.
            if record.springs.starts(with: ".") {
                let shortened = Record(
                    springs: String(record.springs.dropFirst()),
                    contiguousGroupSizes: record.contiguousGroupSizes
                )
                return matchingArrangements(shortened)
            }
            
            // If the record starts with a broken spring...
            if record.springs.starts(with: "#") {
                // If there isn't at least a group left to match, there are no possible arrangements.
                guard let firstGroupSize = record.contiguousGroupSizes.first else {
                    return 0
                }
                
                // If the first group size is greater than the remaining number of springs, there are no possible
                // arrangements.
                guard record.springs.count >= firstGroupSize else {
                    return 0
                }
                
                // If the first number of springs equal to the group size contains an operational spring, there are no
                // possible arrangements.
                if record.springs.prefix(firstGroupSize).contains(".") {
                    return 0
                }
                
                // We remove the first n springs, where n is the group size and remove the first group from the groups
                // left to match.
                var shortened = Record(
                    springs: String(record.springs.dropFirst(firstGroupSize)),
                    contiguousGroupSizes: Array(record.contiguousGroupSizes.dropFirst())
                )
                
                // If the shortened record starts with a broken spring, there are no solutions.
                if shortened.springs.starts(with: "#") {
                    return 0
                }
                
                // If the shortened record starts with an unknown spring, there are only possible arrangements if that
                // unknown spring is operational. We change that spring to an operational one and recursively check
                // again.
                if shortened.springs.starts(with: "?") {
                    shortened.springs = "." + Array(shortened.springs.dropFirst())
                }
                
                return matchingArrangements(shortened)
            }
            
            guard record.springs.starts(with: "?") else {
                return 0
            }
            
            // If the first spring is unknown, we replace it with an operational spring and recursively check again. We
            // also replace it with a broken spring and recursively check again. The number of possible arrangements
            // for the record is the sum of the number possible arrangements for both those cases.
            let possibleRecords = [
                Record(
                    springs: "." + String(record.springs.dropFirst()),
                    contiguousGroupSizes: record.contiguousGroupSizes
                ),
                Record(
                    springs: "#" + String(record.springs.dropFirst()),
                    contiguousGroupSizes: record.contiguousGroupSizes
                ),
            ]
            
            return possibleRecords.reduce(into: 0, { sum, record in
                sum += matchingArrangements(record)
            })
        })
        return memoizedMatchingArrangements(record)
    }
    
    struct Record: Hashable {
        var springs: String
        let contiguousGroupSizes: [Int]
        
        func unfolded() -> Self {
            let springs = Array(repeating: springs, count: 5).joined(separator: "?")
            let contiguousGroupSizes = Array(Array(repeating: contiguousGroupSizes, count: 5).joined())
            
            return Self(springs: springs, contiguousGroupSizes: contiguousGroupSizes)
        }
    }
    
    enum SpringState: Character {
        case operational = "."
        case damaged = "#"
    }
}

extension Day12.Record {
    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: " ")
        
        guard components.count == 2 else {
            return nil
        }
        
        self.springs = components[0]
        self.contiguousGroupSizes = components[1].components(separatedBy: ",").compactMap(Int.init)
    }
}

func memoize<Input: Hashable, Output>(
    _ function: @escaping (Input) -> Output
) -> (Input) -> Output {
    // our item cache
    var storage = [Input: Output]()

    // send back a new closure that does our calculation
    return { input in
        if let cached = storage[input] {
            return cached
        }

        let result = function(input)
        storage[input] = result
        return result
    }
}

func recursiveMemoize<Input: Hashable, Output>(
    _ function: @escaping ((Input) -> Output, Input) -> Output
) -> (Input) -> Output {
    // our item cache
    var storage = [Input: Output]()
    var memo: ((Input) -> Output)!
    
    // send back a new closure that does our calculation
    memo = { input in
        if let cached = storage[input] {
            return cached
        }
        
        let result = function(memo, input)
        storage[input] = result
        return result
    }
    
    return memo
}
