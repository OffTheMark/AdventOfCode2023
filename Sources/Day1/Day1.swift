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
            let file = try readFile()
            
            printTitle("Part 1", level: .title1)
        }
    }
}
