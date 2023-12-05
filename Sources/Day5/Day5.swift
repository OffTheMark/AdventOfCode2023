//
//  Day5.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-05.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import RegexBuilder

struct Day5: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day5",
            abstract: "Solve day 5 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let file = try readFile()
        
        let (seeds, maps) = parse(file)
        printTitle("Part 1", level: .title1)
        let lowestLocation = part1(seeds: seeds, maps: maps)
        print("Lowest location that corresponds to any initial seed number:", lowestLocation, terminator: "\n\n")
    }
    
    private func parse(_ rawValue: String) -> (seeds: [Int], maps: [Path: [Transform]]) {
        let blocks = rawValue.split(separator: "\n\n").map(String.init)
        
        let seeds = blocks[0].removingPrefix("seeds: ")
            .components(separatedBy: " ")
            .compactMap(Int.init)
        
        let maps: [Path: [Transform]] = blocks.dropFirst().reduce(into: [:], { maps, block in
            let lines = block.components(separatedBy: .newlines)
            
            guard lines.count >= 2 else {
                return
            }
            
            guard let path = Path(rawValue: lines[0]) else {
                return
            }
            
            let transforms = lines.dropFirst().compactMap(Transform.init)
            
            maps[path] = transforms
        })
        
        return (seeds, maps)
    }
    
    func part1(seeds: [Int], maps: [Path: [Transform]]) -> Int {
        let destinationsBySource: [String: String] = maps.reduce(into: [:], { result, map in
            result[map.key.source] = map.key.destination
        })
        
        return seeds.map({ seed -> Int in
            location(forSeed: seed, maps: maps, destinationsBySource: destinationsBySource)
        })
        .min()!
    }
    
    private func location(
        forSeed seed: Int,
        maps: [Path: [Transform]],
        destinationsBySource: [String: String]
    )
    -> Int {
        var currentCategory = "seed"
        var value = seed
        
        while currentCategory != "location" {
            let destination = destinationsBySource[currentCategory]!
            let transforms = maps[.init(source: currentCategory, destination: destination), default: []]
            
            if let transform = transforms.first(where: { $0.sourceRange.contains(value) }) {
                value += transform.destinationOffset
            }
            
            currentCategory = destination
        }
        
        return value
    }
    
    struct Path: Hashable {
        let source: String
        let destination: String
    }
    
    struct Transform {
        let sourceStart: Int
        let destinationStart: Int
        let width: Int
        
        var destinationOffset: Int { destinationStart - sourceStart }
        
        var sourceRange: Range<Int> { sourceStart ..< sourceStart + width }
    }
}

extension Day5.Path {
    private static let regex = Regex {
        Capture {
            OneOrMore(.word)
        }
        
        "-to-"
        
        Capture {
            OneOrMore(.word)
        }
        
        " map:"
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        let (_, source, destination) = match.output
        
        self.source = String(source)
        self.destination = String(destination)
    }
}

extension Day5.Transform {
    private static let regex = Regex {
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int($0)
        }
        
        " "
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int($0)
        }
        
        " "
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int($0)
        }
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        let (_, destinationStart, sourceStart, width) = match.output
        
        self.sourceStart = sourceStart
        self.destinationStart = destinationStart
        self.width = width
    }
}
