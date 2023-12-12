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
            sum += record.arrangementsMatchingCriteria()
        })
    }
    
    
    struct Record {
        typealias SpringState = Day12.SpringState
        
        let rawValue: String
        let count: Int
        let knownSpringStatesByIndex: [Int: SpringState]
        let contiguousGroupSizes: [Int]
        let unknownIndices: [Int]
        
        func arrangementsMatchingCriteria() -> Int {
            if unknownIndices.isEmpty {
                return 1
            }
            
            let totalNumberOfBrokenSprings = contiguousGroupSizes.reduce(0, +)
            let numberOfKnownBrokenSprings = knownSpringStatesByIndex.count(where: { $0.value == .damaged })
            let numberOfUnknownBrokenSprings = totalNumberOfBrokenSprings - numberOfKnownBrokenSprings
            
            if numberOfUnknownBrokenSprings == unknownIndices.count {
                return 1
            }
            
            let permutations = unknownIndices.permutations()
            
            return permutations.count(where: { permutation in
                // TODO
                false
            })
        }
        
        private func matchesCriteria(_ springStatesByIndex: [Int: SpringState]) -> Bool {
            // TODO
            false
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
        
        var unknownIndices = [Int]()
        let knownSpringStatesByIndex: [Int: SpringState] = components[0].enumerated()
            .reduce(into: [:], { result, pair in
                let (index, character) = pair
                
                guard let state = SpringState(rawValue: character) else {
                    unknownIndices.append(index)
                    return
                }
                result[index] = state
            })
        let contiguousGroupSizes = components[1].components(separatedBy: ",").compactMap(Int.init)
        
        self.rawValue = rawValue
        self.count = components[0].count
        self.knownSpringStatesByIndex = knownSpringStatesByIndex
        self.contiguousGroupSizes = contiguousGroupSizes
        self.unknownIndices = unknownIndices
    }
}
