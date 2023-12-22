//
//  Day21.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-21.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections

struct Day21: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day21",
            abstract: "Solve day 21 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid<Tile>(rawValue: try readFile(), valueForCharacter: Tile.init)
        
        printTitle("Part 1", level: .title1)
        let steps = 64
        let numberOfGardenPlotsReached = part1(grid: grid, steps: steps)
        print("Number of garden plots reached in \(steps) steps:", numberOfGardenPlotsReached)
    }
    
    private func part1(grid: Grid<Tile>, steps: Int) -> Int {
        let startingPosition = grid.valuesByPosition.keys
            .first(where: { grid.valuesByPosition[$0] == .startingPosition })!
        
        var visited = Set<Point2D>()
        var queue: Deque<Node> = [Node(position: startingPosition)]
        
        while let current = queue.popFirst() {
            if current.steps > steps {
                continue
            }
            
            let validMoves = grid.validMoves(from: current.position)
            for neighbor in validMoves where !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append(current.movingTo(neighbor))
            }
        }
        
        return visited.count(where: { position in
            let horizontalDistance = position.x - startingPosition.x
            let verticalDistance = position.y - startingPosition.y
            
            return (horizontalDistance + verticalDistance) % 2 == steps % 2
        })
    }
}

private struct Node: Hashable {
    let position: Point2D
    let steps: Int
    
    func movingTo(_ position: Point2D) -> Self {
        Self(
            position: position,
            steps: steps + 1
        )
    }
}

extension Node {
    init(position: Point2D) {
        self.position = position
        self.steps = 0
    }
}

private enum Tile: Character {
    case rock = "#"
    case startingPosition = "S"
    case garden = "."
}

extension Grid<Tile> {
    static let validMoves: [Translation2D] = [
        .up,
        .right,
        .down,
        .left
    ]
    
    func validMoves(from position: Point2D) -> Set<Point2D> {
        guard let value = valuesByPosition[position] else {
            return []
        }
        
        if value == .rock {
            return []
        }
        
        return Self.validMoves.reduce(into: Set<Point2D>(), { result, translation in
            let neighbor = position.applying(translation)
            
            if !contains(neighbor) {
                return
            }
            
            if valuesByPosition[neighbor] == .rock {
                return
            }
            
            result.insert(neighbor)
        })
    }
}
