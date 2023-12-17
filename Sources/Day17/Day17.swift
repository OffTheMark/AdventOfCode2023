//
//  Day17.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-17.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections

struct Day17: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day17",
            abstract: "Solve day 17 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let grid = Grid<Int>(rawValue: try readFile(), valueForCharacter: { Int(String($0)) })
        
        printTitle("Part 1", level: .title1)
        let leastHeatLoss = part1(grid: grid)
        print("Least heat lost incurred from start to end:", leastHeatLoss)
    }
    
    func part1(grid: Grid<Int>) -> Int {
        let start = grid.origin
        let end = Point2D(x: grid.maxX, y: grid.maxY)
        
        return leastHeatLoss(from: start, to: end, in: grid)
    }
    
    private func leastHeatLoss(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid<Int>
    ) -> Int {
        struct Node {
            let position: Point2D
            let path: [Point2D]
            let moves: Deque<Direction>
            let visited: Set<Point2D>
            let cost: Int
            
            func availableMoves() -> [Direction] {
                let lastThreeMoves = moves.suffix(3)
                
                guard let lastMove = lastThreeMoves.last else {
                    return Direction.allCases
                }
                
                var availableMoves = lastMove.availableDirections()
                let hasDoneSameMoveThrice = Set(lastThreeMoves).count == 1
                if hasDoneSameMoveThrice {
                    availableMoves.removeAll(where: { $0 == lastMove })
                }
                return availableMoves
            }
        }
        
        let firstNode = Node(
            position: start,
            path: [start],
            moves: [],
            visited: [],
            cost: 0
        )
        var costByPosition = [Point2D: Int]()
        
        var frontier: Deque<Node> = [firstNode] {
            didSet {
                frontier.sort(by: { $0.cost < $1.cost })
            }
        }
        
        while let current = frontier.popFirst() {
            if current.position == end {
                return current.cost
            }
            
            if !current.moves.isEmpty {
                costByPosition[current.position] = current.cost
            }
            
            let availableMoves = current.availableMoves()
            
            for move in availableMoves {
                let neighbor = current.position.applying(move.translation)
                
                guard let cost = grid.valuesByPosition[neighbor] else {
                    continue
                }
                
                if current.visited.contains(neighbor) {
                    continue
                }
                
                let node = Node(
                    position: neighbor,
                    path: current.path + [neighbor],
                    moves: current.moves + [move],
                    visited: current.visited.union([neighbor]),
                    cost: current.cost + cost
                )
                
                if let previousCost = costByPosition[neighbor], previousCost < node.cost {
                    continue
                }
                
                frontier.append(node)
            }
        }
        
        fatalError("Could not find path from \(start) to \(end)")
    }
    
    enum Direction: Hashable, CaseIterable {
        case up
        case right
        case down
        case left
        
        func rotatedLeft() -> Direction {
            switch self {
            case .up:
                .left
            case .right:
                .up
            case .down:
                .right
            case .left:
                .down
            }
        }
        
        func rotatedRight() -> Direction {
            switch self {
            case .up:
                .right
            case .right:
                .down
            case .down:
                .left
            case .left:
                .up
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
        
        func availableDirections() -> [Direction] {
            [rotatedLeft(), self, rotatedRight()]
        }
    }
}
