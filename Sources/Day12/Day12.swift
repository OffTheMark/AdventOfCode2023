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
        let sumOfArrangementsMatchingCriteria = part1(records: records)
        print("Sum of all arrangements matching criteria:", sumOfArrangementsMatchingCriteria)
    }
    
    func part1(records: [Record]) -> Int {
        records.reduce(into: 0, { sum, record in
            let matchingArrangements = matchingArrangements(for: record)
            sum += matchingArrangements
        })
    }
    
    func matchingArrangements(for record: Record) -> Int {
        var matchingArrangementsByRecord = [Record: Int]()
        
        func recursiveMatchingArrangements(for record: Record) -> Int {
            if let result = matchingArrangementsByRecord[record] {
                return result
            }
            
            if record.springs.isEmpty {
                return if record.contiguousGroupSizes.isEmpty {
                    1
                }
                else {
                    0
                }
            }
            
            let operationalOrUnknown: Set<Character> = [".", "?"]
            if record.contiguousGroupSizes.isEmpty, record.springs.allSatisfy({ operationalOrUnknown.contains($0)}) {
                return 1
            }
            
            let brokenOrUnknown: Set<Character> = ["#", "?"]
            let countOfBrokenOrUnknown = record.springs.count(where: { brokenOrUnknown.contains($0) })
            let countOfBrokenSprings = record.contiguousGroupSizes.reduce(0, +)
            
            if countOfBrokenOrUnknown < countOfBrokenSprings {
                return 0
            }
            
            if countOfBrokenOrUnknown == countOfBrokenSprings, 
                record.springs.count < countOfBrokenOrUnknown + max(0, record.contiguousGroupSizes.count - 1) {
                return 0
            }
            
            if record.springs.starts(with: ".") {
                let shortened = Record(
                    springs: String(record.springs.dropFirst()),
                    contiguousGroupSizes: record.contiguousGroupSizes
                )
                let result = recursiveMatchingArrangements(for: shortened)
                matchingArrangementsByRecord[record] = result
                
                return result
            }
            
            if record.springs.starts(with: "#") {
                guard let firstGroupSize = record.contiguousGroupSizes.first else {
                    return 0
                }
                
                guard record.springs.count >= firstGroupSize else {
                    return 0
                }
                
                if record.springs.prefix(firstGroupSize).contains(".") {
                    return 0
                }
                
                var shortened = Record(
                    springs: String(record.springs.dropFirst(firstGroupSize)),
                    contiguousGroupSizes: Array(record.contiguousGroupSizes.dropFirst())
                )
                
                if shortened.springs.starts(with: "#") {
                    return 0
                }
                
                if shortened.springs.starts(with: "?") {
                    shortened.springs = "." + Array(shortened.springs.dropFirst())
                }
                
                let result = recursiveMatchingArrangements(for: shortened)
                matchingArrangementsByRecord[record] = result
                return result
            }
            
            guard record.springs.starts(with: "?") else {
                return 0
            }
            
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
            
            let result = possibleRecords.reduce(into: 0, { sum, record in
                sum += recursiveMatchingArrangements(for: record)
            })
            matchingArrangementsByRecord[record] = result
            return result
        }
        
        return recursiveMatchingArrangements(for: record)
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
