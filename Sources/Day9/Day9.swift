//
//  Day9.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-08.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser

struct Day9: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day9",
            abstract: "Solve day 9 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let lines = try readLines()
        
        // TODO
    }
}
