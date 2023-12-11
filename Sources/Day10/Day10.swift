//
//  Day10.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-10.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections

struct Day10: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day10",
            abstract: "Solve day 10 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let graph = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let stepsToFarthestPoint = part1(graph: graph)
        print(
            "Steps from the starting position to the pointest farthest from the starting position:",
            stepsToFarthestPoint,
            terminator: "\n\n"
        )
    }
    
    private func parse(_ lines: [String]) -> Graph {
        let map = lines.enumerated().reduce(into: [Point2D: Pipe](), { map, pair in
            let (y, line) = pair
            
            for (x, character) in line.enumerated() {
                guard let pipe = Pipe(rawValue: character) else {
                    continue
                }
                
                let point = Point2D(x: x, y: y)
                map[point] = pipe
            }
        })
        return Graph(map: map)
    }
    
    func part1(graph: Graph) -> Int {
        let start = graph.map
            .first(where: { _, pipe in
                pipe == .startingPosition
            })!
            .key
        let loop = depthFirstSearch(from: start, to: start, graph: graph)
        
        return loop.count / 2
    }
    
    private func depthFirstSearch(
        from start: Point2D,
        to end: Point2D,
        graph: Graph
    ) -> [Point2D] {
        struct Node {
            let point: Point2D
            let parent: Point2D?
            let path: [Point2D]
            
            init(point: Point2D, path: [Point2D]) {
                self.point = point
                self.path = path
                if path.count >= 2 {
                    self.parent = path[path.count - 2]
                }
                else {
                    self.parent = nil
                }
            }
        }
        let startNode = Node(point: start, path: [start])
        
        var visited: Set<Point2D> = [start]
        var stack: Deque<Node> = [startNode]
        
        outer: while let current = stack.last {
            let neighbors = graph.neighbors(of: current.point)
            
            guard neighbors.count > 0 else {
                stack.removeLast()
                continue
            }
            
            for neighbor in neighbors {
                if !visited.contains(neighbor)  {
                    let nextNode = Node(point: neighbor, path: current.path + [neighbor])
                    visited.insert(neighbor)
                    stack.append(nextNode)
                    continue outer
                }
                else if neighbor != current.parent {
                    break outer
                }
            }
            
            stack.removeLast()
        }
        return stack.removeLast().path
    }
    
    enum Pipe: Character {
        case vertical = "|"
        case horizontal = "-"
        case northEastBend = "L"
        case northWestBend = "J"
        case southWestBend = "7"
        case southEastBend = "F"
        case startingPosition = "S"
    
        func connections(for point: Point2D) -> Set<Point2D> {
            let translations: Set<Translation2D> = switch self {
            case .vertical:
                [.up, .down]
                
            case .horizontal:
                [.left, .right]
                
            case .northEastBend:
                [.up, .right]
                
            case .northWestBend:
                [.up, .left]
                
            case .southWestBend:
                [.down, .left]
                
            case .southEastBend:
                [.down, .right]
                
            case .startingPosition:
                [.up, .down, .left, .right]
            }
            
            return Set(translations.map({ point.applying($0) }))
        }
    }
    
    struct Graph {
        let map: [Point2D: Pipe]
        
        func neighbors(of point: Point2D) -> Set<Point2D> {
            guard let pipe = map[point] else {
                return []
            }
            
            return pipe.connections(for: point)
                .filter({ neighbor in
                    guard let neighboringPipe = map[neighbor] else {
                        return false
                    }
                    
                    return neighboringPipe.connections(for: neighbor).contains(point)
                })
        }
    }
}
