//
//  Day4.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-03.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day4: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day4",
            abstract: "Solve day 4 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let lines = try readLines()
        // TODO
    }
}
