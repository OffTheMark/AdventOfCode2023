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
        let source: Int
        let destination: Int
        let width: Int
        
        var offset: Int { destination - source }
        
        var sourceRange: Range<Int> { source ..< source + width }
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
        
        self.source = sourceStart
        self.destination = destinationStart
        self.width = width
    }
}

extension Day5.Map {
    func map(_ value: Int) -> Int {
        guard let transform = transforms.first(where: { $0.sourceRange.contains(value) }) else {
            return value
        }
        
        return value + transform.offset
    }
    
    func map(_ range: Range<Int>) -> [Range<Int>] {
        // Adapted from Daniel Gauthier's Swift solution for day 5 part 2:
        // https://github.com/danielmgauthier/advent-of-code-2023/blob/main/Sources/AdventOfCode2023/Day5.swift
        let sortedTransforms = transforms.sorted(by: { $0.source < $1.source })
        var transformedRanges = [Range<Int>]()
        
        var cursor = range.lowerBound
        while cursor < range.upperBound {
            let rangeWithSameOffset: Range<Int>
            
            // If the current range start is contained in a transform, we can simply offset the part of the range
            // that overlaps with the transform's range by the transform's offset.
            if let transform = sortedTransforms.first(where: { $0.sourceRange.contains(cursor) }) {
                // We move the cursor to the end of the transform's source range if it is included in the input range.
                // If it's not we move to the end of the input range.
                let upperBound = min(transform.sourceRange.upperBound, range.upperBound)
                rangeWithSameOffset = cursor ..< upperBound
                
                // We offset the range with the same offset as the cursor and add it to the result.
                let transformedRange = rangeWithSameOffset.offset(by: transform.offset)
                transformedRanges.append(transformedRange)
            }
            // If not, the current range start is not part of a transform. We try to find the next transform who
            // overlaps with the remaining part of the input range.
            else {
                // If there is such a range, we move up to the start of this range.
                if let transform = sortedTransforms.first(where: {
                    $0.sourceRange.overlaps(cursor ..< range.upperBound)
                }) {
                    rangeWithSameOffset = cursor ..< transform.source
                }
                // If there is no such range, we move up to the end of the input range.
                else {
                    rangeWithSameOffset = cursor ..< range.upperBound
                }
                
                // We add the range with the same offset as the cursor to the result. This whole range does not change
                // value with the current map.
                transformedRanges.append(rangeWithSameOffset)
            }
            
            cursor = rangeWithSameOffset.upperBound
        }
        
        return transformedRanges
    }
}

extension Range<Int> {
    func offset(by offset: Int) -> Range<Int> {
        lowerBound + offset ..< upperBound + offset
    }
}
