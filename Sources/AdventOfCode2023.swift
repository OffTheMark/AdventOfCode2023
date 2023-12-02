// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct AdventOfCode2023: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "aoc2023",
            abstract: "A program to solve Advent of Code 2023 puzzles",
            version: "0.0.1",
            subcommands: [
                Commands.Day1.self,
                Commands.Day2.self,
                Commands.Day3.self,
            ]
        )
    }
    
    mutating func run() throws {
        print("Hello, world!")
    }
}

enum Commands {}
