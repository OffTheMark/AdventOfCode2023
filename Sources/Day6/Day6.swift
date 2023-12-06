//
//  Day6.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-06.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser
import RegexBuilder

struct Day6: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day6",
            abstract: "Solve day 6 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let races = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let productOfWaysToBeatRaces = part1(races: races)
        print(
            "Product of the number of ways to beat the record in each race:",
            productOfWaysToBeatRaces,
            terminator: "\n\n"
        )
    }
    
    private func parse(_ lines: [String]) -> [RaceRecord] {
        let times: [Int] = lines[0]
            .removingPrefix("Time:")
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .compactMap({ Int(String($0)) })
        let recordDistances: [Int] = lines[1]
            .removingPrefix("Distance:")
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .compactMap({ Int(String($0)) })
        
        return zip(times, recordDistances).map({ time, recordDistance in
            RaceRecord(time: time, recordDistance: recordDistance)
        })
    }
    
    func part1(races: [RaceRecord]) -> Int {
        races.reduce(into: 1, { product, race in
            let waysToPlay = 0 ... race.time
            let waysToBeatRecord = waysToPlay.count(where: { timeHoldingButton in
                let remainingTime = race.time - timeHoldingButton
                let distanceTraveled = remainingTime * timeHoldingButton
                return distanceTraveled > race.recordDistance
            })
            
            product *= waysToBeatRecord
        })
    }
    
    struct RaceRecord {
        let time: Int
        let recordDistance: Int
    }
}
