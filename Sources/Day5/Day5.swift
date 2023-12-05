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
        let destinationsToSource: [String: String] = maps.reduce(into: [:], { result, map in
            result[map.key.source] = map.key.destination
        })
        
        var currentCategory = "seed"
        
        // TODO
        return 0
    }
    
    struct Path: Hashable {
        let source: String
        let destination: String
    }
    
    struct Transform {
        let source: Int
        let destination: Int
        let width: Int
        
        var sourceRange: Range<Int> {
            source ..< source + width
        }
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
        
        let (_, source, destination, width) = match.output
        
        self.source = source
        self.destination = destination
        self.width = width
    }
}
