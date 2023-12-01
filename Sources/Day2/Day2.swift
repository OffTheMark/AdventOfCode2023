//
//  Day2.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day2: DayCommand {
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
        }
    }
}
