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
        let steps = try readFile().components(separatedBy: ",").compactMap(Step.init)
        
        printTitle("Part 1", level: .title1)
        let sumOfResults = part1(steps: steps)
        print("Sum of the results of the HASH algorithm:", sumOfResults, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let focusingPower = part2(steps: steps)
        print("Focusing power of the resulting lens configuration:", focusingPower)
    }
    
    func part1(steps: [Step]) -> Int {
        steps.reduce(into: 0, { sum, step in
            let hashValue = hashValue(for: step.rawValue)
            sum += hashValue
        })
    }
    
    func part2(steps: [Step]) -> Int {
        struct Lens {
            let label: String
            let focalLength: Int
        }
        
        var lensByBoxes = [Int: [Lens]]()
        
        for step in steps {
            let box = hashValue(for: step.label)
            
            switch step.operation {
            case .remove:
                lensByBoxes[box]?.removeAll(where: { $0.label == step.label })
                if lensByBoxes[box, default: []].isEmpty {
                    lensByBoxes.removeValue(forKey: box)
                }
                
            case .installLens(let focalLength):
                let insertedLens = Lens(label: step.label, focalLength: focalLength)
                
                if let index = lensByBoxes[box, default: []].firstIndex(where: { $0.label == step.label }) {
                    lensByBoxes[box, default: []].remove(at: index)
                    lensByBoxes[box, default: []].insert(insertedLens, at: index)
                }
                else {
                    lensByBoxes[box, default: []].append(insertedLens)
                }
            }
        }
        
        return lensByBoxes.reduce(into: 0, { sum, element in
            let (box, lenses) = element
            
            sum += lenses.enumerated().reduce(into: 0, { sum, element in
                let (slot, lens) = element
                let focusingPower = (box + 1) * (slot + 1) * lens.focalLength
                sum += focusingPower
            })
        })
    }
    
    private func hashValue(for step: String) -> Int {
        var currentValue = 0
        
        for character in step {
            guard let asciiCode = character.asciiValue.map(Int.init) else {
                continue
            }
            
            currentValue += asciiCode
            currentValue *= 17
            (_, currentValue) = currentValue.quotientAndRemainder(dividingBy: 256)
        }
        
        return currentValue
    }
    
    struct Step {
        typealias Operation = Day15.Operation
        
        let rawValue: String
        let label: String
        let operation: Operation
    }
    
    enum Operation {
        case remove
        case installLens(focalLength: Int)
    }
}

extension Day15.Step {
    init?(rawValue: String) {
        guard let index = rawValue.firstIndex(where: { !$0.isLetter }) else {
            return nil
        }
        
        self.rawValue = rawValue
        self.label = String(rawValue[rawValue.startIndex ..< index])
        
        guard let operation = Operation(rawValue: String(rawValue[index ..< rawValue.endIndex])) else {
            return nil
        }
                                        
        self.operation = operation
    }
}

extension Day15.Operation {
    init?(rawValue: String) {
        if rawValue.isEmpty {
            return nil
        }
        
        switch rawValue[rawValue.startIndex] {
        case "-":
            self = .remove
            
        case "=":
            guard let focalLength = Int(String(rawValue.dropFirst())) else {
                return nil
            }
            
            self = .installLens(focalLength: focalLength)
            
        default:
            return nil
        }
    }
}
