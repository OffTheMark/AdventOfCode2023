//
//  Day3.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-02.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

extension Commands {
    struct Day3: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day3",
                abstract: "Solve day 3 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let grid = Grid(lines: try readLines())
            
            printTitle("Part 1", level: .title1)
            let sumOfPartNumbers = part1(grid: grid)
            print("Sum of all the part numbers in the engine schematic:", sumOfPartNumbers, terminator: "\n\n")
        }
        
        private func part1(grid: Grid) -> Int {
            var numbersNotPartNumbers = Set<Number>()
            
            let sum = grid.numbers.reduce(into: 0, { sum, number in
                let adjacentPoints = number.adjacentPoints()
                let isPartNumber = adjacentPoints.contains(where: { point in
                    grid.symbolsByPosition.keys.contains(point)
                })
                
                if isPartNumber {
                    sum += number.value
                }
                else {
                    numbersNotPartNumbers.insert(number)
                }
            })
            
            return sum
        }
    }
}

private struct Grid {
    let numbers: Set<Number>
    let symbolsByPosition: [Point2D: Character]
}

extension Grid {
    init(lines: [String]) {
        var numbers = Set<Number>()
        var symbolsByPosition = [Point2D: Character]()
        
        for (y, line) in lines.enumerated() {
            var currentNumber: (start: Point2D, rawValue: String)?
            
            for (x, character) in line.enumerated() {
                let position = Point2D(x: x, y: y)
                
                if character.isNumber {
                    if let current = currentNumber {
                        currentNumber = (current.start, current.rawValue + String(character))
                    }
                    else {
                        currentNumber = (position, String(character))
                    }
                    
                    continue
                }
                
                if let current = currentNumber, let value = Int(current.rawValue) {
                    let deltas = 0 ..< current.rawValue.count
                    let positions = Set(deltas.map({ current.start.applying(.init(deltaX: $0, deltaY: 0)) }))
                    let number = Number(value: value, positions: positions)
                    
                    numbers.insert(number)
                    currentNumber = nil
                }
                
                if character != "." {
                    symbolsByPosition[position] = character
                }
            }
        }
        
        self.numbers = numbers
        self.symbolsByPosition = symbolsByPosition
    }
}

private struct Number: Hashable {
    let value: Int
    let positions: Set<Point2D>
    
    func adjacentPoints() -> Set<Point2D> {
        let translations: [Translation2D] = [
            .up,
            .upRight,
            .right,
            .downRight,
            .down,
            .downLeft,
            .left,
            .upLeft,
        ]
        
        return positions
            .reduce(into: Set<Point2D>(), { result, coordinate in
                for translation in translations {
                    let translated = coordinate.applying(translation)
                    result.insert(translated)
                }
            })
            .subtracting(positions)
    }
}

struct Point2D: Hashable {
    var x: Int
    var y: Int
    
    func adjacentPoints(includingDiagonals includesDiagonals: Bool) -> Set<Point2D> {
        var translations: [Translation2D] = [
            .up,
            .right,
            .down,
            .left,
        ]
        if includesDiagonals {
            translations += [
                .upRight,
                .downRight,
                .downLeft,
                .upLeft,
            ]
        }
        
        return Set(translations.map({ applying($0) }))
    }
    
    mutating func apply(_ translation: Translation2D) {
        x += translation.deltaX
        y += translation.deltaY
    }
    
    func applying(_ translation: Translation2D) -> Self {
        var copy = self
        copy.apply(translation)
        return copy
    }
}

struct Translation2D: Hashable {
    var deltaX: Int
    var deltaY: Int
}

private extension Translation2D {
    static let up = Self(deltaX: 0, deltaY: -1)
    static let upRight = Self(deltaX: 1, deltaY: -1)
    static let right = Self(deltaX: 1, deltaY: 0)
    static let downRight = Self(deltaX: 1, deltaY: 1)
    static let down = Self(deltaX: 0, deltaY: 1)
    static let downLeft = Self(deltaX: -1, deltaY: 1)
    static let left = Self(deltaX: -1, deltaY: 0)
    static let upLeft = Self(deltaX: -1, deltaY: -1)
}
