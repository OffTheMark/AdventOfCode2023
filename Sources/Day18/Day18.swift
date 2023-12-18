//
//  Day18.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-17.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import RegexBuilder

struct Day18: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day18",
            abstract: "Solve day 18 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let instructions = try readLines().compactMap(Instruction.init)
        
        printTitle("Part1", level: .title1)
        let volumeOfLagoon = part1(instructions: instructions)
        print("How many cubic meters of lava could the lagoon hold?", volumeOfLagoon, terminator: "\n\n")
        
        printTitle("Part1", level: .title1)
        let correctVolumeOfLagoon = part2(instructions: instructions)
        print(
            "How many cubic meters of lava could the lagoon hold with the correct instructions?",
            correctVolumeOfLagoon
        )
    }
    
    func part1(instructions: [Instruction]) -> Int {
        var currentPosition: Point2D = .zero
        
        // Using the shoelace formula and Pick's theorem to calculate the area occupied by the interior as well as
        // the perimeter.
        var perimeterArea = 0
        let interiorArea = instructions
            .reduce(into: 0, { shoeLaceArea, instruction in
                let previousPosition = currentPosition
                currentPosition.apply(instruction.translation)
                
                shoeLaceArea += previousPosition.x * currentPosition.y  - currentPosition.x * previousPosition.y
                perimeterArea += instruction.length
            }) / 2
        
        return interiorArea + perimeterArea / 2 + 1
    }
    
    func part2(instructions: [Instruction]) -> Int {
        let instructions = instructions.compactMap({ $0.makeInstructionFromColor() })
        return part1(instructions: instructions)
    }
    
    struct Instruction {
        typealias Direction = Day18.Direction
        
        let direction: Direction
        let length: Int
        let color: String
        
        func makeInstructionFromColor() -> Self? {
            guard color.count == 6 else {
                return nil
            }
            
            var color = color
            guard let direction = Direction(hexadecimalCharacter: color.removeLast()) else {
                return nil
            }
            
            guard let length = Int(color, radix: 16) else {
                return nil
            }
            
            return Self(direction: direction, length: length, color: color)
        }
        
        var translation: Translation2D { direction.translation * length }
        
    }
    
    enum Direction: Character {
        case up = "U"
        case right = "R"
        case down = "D"
        case left = "L"
        
        init?(hexadecimalCharacter: Character) {
            switch hexadecimalCharacter {
            case "0":
                self = .right
            
            case "1":
                self = .down
            
            case "2":
                self = .left
                
            case "3":
                self = .up
                
            default:
                return nil
            }
        }
        
        var translation: Translation2D {
            switch self {
            case .up:
                Translation2D(deltaX: 0, deltaY: -1)
            case .right:
                Translation2D(deltaX: 1, deltaY: 0)
            case .down:
                Translation2D(deltaX: 0, deltaY: 1)
            case .left:
                Translation2D(deltaX: -1, deltaY: 0)
            }
        }
    }
}

extension Day18.Instruction {
    private static let regex = Regex {
        TryCapture {
            One(.word)
        } transform: { substring -> Direction? in
            guard let character = substring.first else {
                return nil
            }
            
            return Direction(rawValue: character)
        }
        
        " "
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        " (#"
        
        TryCapture {
            OneOrMore(.hexDigit)
        } transform: {
            String($0)
        }
        
        ")"
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        self.direction = match.output.1
        self.length = match.output.2
        self.color = match.output.3
    }
}
