//
//  Day20.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-19.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser

struct Day20: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day20",
            abstract: "Solve day 20 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        printTitle("Part 1", level: .title1)
    }
}
