//
//  Day15.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-14.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser

struct Day15: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day15",
            abstract: "Solve day 15 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        
    }
}
