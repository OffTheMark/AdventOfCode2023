//
//  Day5.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-05.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
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
        
        printTitle("Part 2", level: .title1)
        let lowestLocationForSeedRanges = part2(seeds: seeds, maps: maps)
        print("Lowest location that corresponds to any initial seed number range:", lowestLocationForSeedRanges)
        
    }
    
    private func parse(_ rawValue: String) -> (seeds: [Int], maps: [Map]) {
        let blocks = rawValue.split(separator: "\n\n").map(String.init)
        
        let seeds = blocks[0].removingPrefix("seeds: ")
            .components(separatedBy: " ")
            .compactMap(Int.init)
        
        let maps: [Map] = blocks.dropFirst().compactMap({ block in
            let lines = block.components(separatedBy: .newlines)
            
            guard lines.count >= 2 else {
                return nil
            }
            
            let transforms = lines.dropFirst().compactMap(Transform.init)
            return Map(transforms: transforms)
        })
        
        return (seeds, maps)
    }
    
    func part1(seeds: [Int], maps: [Map]) -> Int {
        return seeds.map({ seed -> Int in
            location(forSeed: seed, maps: maps)
        })
        .min()!
    }
    
    func part2(seeds: [Int], maps: [Map]) -> Int {
        // Adapted from Daniel Gauthier's Swift solution for day 5 part 2:
        // https://github.com/danielmgauthier/advent-of-code-2023/blob/main/Sources/AdventOfCode2023/Day5.swift
        let seedRanges: [Range<Int>] = seeds.chunks(ofCount: 2).map({ chunk in
            let start = chunk.first!
            let width = chunk.last!
            return start ..< start + width
        })
        
        var valueRanges = seedRanges
        for map in maps {
            let newRanges: [Range<Int>] = valueRanges.flatMap({ valueRange in
                map.map(valueRange)
            })
            valueRanges = newRanges
        }
        
        return valueRanges.min(by: { $0.lowerBound < $1.lowerBound })!
            .lowerBound
    }
    
    private func location(
        forSeed seed: Int,
        maps: [Map]
    ) -> Int {
        maps.reduce(into: seed, { result, map in
            result = map.map(result)
        })
    }
    
    struct Map {
        let transforms: [Transform]
    }
    
    struct Transform {
        let sourceStart: Int
        let destinationStart: Int
        let width: Int
        
        var destinationOffset: Int { destinationStart - sourceStart }
        
        var sourceRange: Range<Int> { sourceStart ..< sourceStart + width }
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

extension Day5.Map {
    func map(_ value: Int) -> Int {
        guard let transform = transforms.first(where: { $0.sourceRange.contains(value) }) else {
            return value
        }
        
        return value + transform.destinationOffset
    }
    
    func map(_ range: Range<Int>) -> [Range<Int>] {
        // Adapted from Daniel Gauthier's Swift solution for day 5 part 2:
        // https://github.com/danielmgauthier/advent-of-code-2023/blob/main/Sources/AdventOfCode2023/Day5.swift
        let sortedTransforms = transforms.sorted(by: { $0.sourceStart < $1.sourceStart })
        var newRanges = [Range<Int>]()
        
        var currentRangeStart = range.lowerBound
        while currentRangeStart < range.upperBound {
            var newRange: Range<Int>
            
            // If the current range start is contained in a transform, we can simply offset
            if let transform = sortedTransforms.first(where: { $0.sourceRange.contains(currentRangeStart) }) {
                let upperBound = min(transform.sourceRange.upperBound, range.upperBound)
                newRange = currentRangeStart ..< upperBound
                
                let transformedRange = newRange.offset(by: transform.destinationOffset)
                newRanges.append(transformedRange)
            }
            else {
                if let transform = sortedTransforms.first(where: { $0.sourceStart > currentRangeStart }) {
                    newRange = currentRangeStart ..< transform.sourceStart
                }
                else {
                    newRange = currentRangeStart ..< range.upperBound
                }
                
                newRanges.append(newRange)
            }
            
            currentRangeStart = newRange.upperBound
        }
        
        return newRanges
    }
}

extension Range<Int> {
    func offset(by offset: Int) -> Range<Int> {
        lowerBound + offset ..< upperBound + offset
    }
}
