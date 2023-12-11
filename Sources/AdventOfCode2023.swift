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
                Day1.self,
                Day2.self,
                Day3.self,
                Day4.self,
                Day5.self,
                Day6.self,
                Day7.self,
                Day8.self,
                Day9.self,
                Day10.self,
                Day11.self,
            ]
        )
    }
}
