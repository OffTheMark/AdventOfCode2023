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
        let leastHeatLossWithCrucibles = part1(grid: grid)
        print(
            "Least heat lost incurred from start to end with crucibles:",
            leastHeatLossWithCrucibles,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let leastHeatLossWithUltraCrucibles = part2(grid: grid)
        print("Least heat lost incurred from start to end with ultra crucibles:", leastHeatLossWithUltraCrucibles)
    }
    
    func part1(grid: Grid<Int>) -> Int {
        let start = grid.origin
        let end = Point2D(x: grid.maxX, y: grid.maxY)
        
        return leastHeatLoss(
            from: start,
            to: end,
            in: grid, 
            availableDirectionsForState: { state in
                var availableMoves: [Direction] = [state.direction.rotatedLeft()]
                if state.distanceWithoutTurning < 3 {
                    availableMoves.append(state.direction)
                }
                availableMoves.append(state.direction.rotatedRight())
                return availableMoves
            }
        )
    }
    
    func part2(grid: Grid<Int>) -> Int {
        let start = grid.origin
        let end = Point2D(x: grid.maxX, y: grid.maxY)
        
        return leastHeatLoss(
            from: start,
            to: end,
            in: grid,
            availableDirectionsForState: { state in
                if state.distanceWithoutTurning < 4 {
                    return [state.direction]
                }
                
                if state.distanceWithoutTurning < 10 {
                    return [
                        state.direction.rotatedLeft(),
                        state.direction,
                        state.direction.rotatedRight()
                    ]
                }
                
                return [state.direction.rotatedLeft(), state.direction.rotatedRight()]
            }
        )
    }
    
    private func leastHeatLoss(
        from start: Point2D,
        to end: Point2D,
        in grid: Grid<Int>,
        availableDirectionsForState: @escaping (State) -> [Direction]
    ) -> Int {
        // Based on rickzwankce's solution for day 17, using Dijsktra's algorithm
        // https://github.com/rizwankce/AdventOfCode/blob/master/2023/Sources/Day17.swift
        struct Node: Comparable {
            let state: State
            let cost: Int
            let priority: Int
            
            var position: Point2D { state.position }
            var direction: Direction { state.direction }
            var distanceWithoutTurning: Int { state.distanceWithoutTurning }
            
            func availableDirections() -> [Direction] {
                var availableMoves: [Direction] = [direction.rotatedLeft()]
                if state.distanceWithoutTurning < 3 {
                    availableMoves.append(direction)
                }
                availableMoves.append(direction.rotatedRight())
                return availableMoves
            }
            
            static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.priority < rhs.priority
            }
        }
        
        let firstStates = [
            State(position: start, direction: .right, distanceWithoutTurning: 1),
            State(position: start, direction: .down, distanceWithoutTurning: 1)
        ]
        var costByState = [State: Int]()
        var visited = Set<State>()
        
        var frontier = Heap<Node>()
        for state in firstStates {
            let node = Node(state: state, cost: 0, priority: 1)
            frontier.insert(node)
        }
        
        while let current = frontier.popMin() {
            if current.position == end {
                return current.cost
            }
            
            let (newlyVisited, _) = visited.insert(current.state)
            if !newlyVisited {
                continue
            }
            
            let availableDirections = availableDirectionsForState(current.state)
            for direction in availableDirections {
                let neighbor = current.position.applying(direction.translation)
                
                guard let cost = grid.valuesByPosition[neighbor] else {
                    continue
                }
                
                let distanceWithoutTurning = if direction == current.direction {
                    current.distanceWithoutTurning + 1
                }
                else {
                    1
                }
                let state = State(
                    position: neighbor,
                    direction: direction,
                    distanceWithoutTurning: distanceWithoutTurning
                )
                let node = Node(
                    state: state,
                    cost: current.cost + cost,
                    priority: current.cost + current.position.manhattanDistance(to: neighbor)
                )
                
                if let previousCost = costByState[state], previousCost < node.cost {
                    continue
                }
                
                costByState[state] = node.cost
                frontier.insert(node)
            }
        }
        
        fatalError("Could not find path from \(start) to \(end)")
    }
    
    struct State: Hashable {
        let position: Point2D
        let direction: Direction
        let distanceWithoutTurning: Int
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
        
    }
}
