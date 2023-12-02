//
//  Day3.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-02.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

extension Commands {
    struct Day3: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day3",
                abstract: "Solve day 3 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let lines = try readLines()
            // TODO
        }
    }
}
