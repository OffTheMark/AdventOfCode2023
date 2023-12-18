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
        let (stepsToFarthestPoint, loop) = part1(graph: graph)
        print(
            "Steps from the starting position to the pointest farthest from the starting position:",
            stepsToFarthestPoint,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        let enclosedTileCount = part2(graph: graph, loop: loop)
        print("Number of enclosed tiles:", enclosedTileCount)
    }
    
    private func parse(_ lines: [String]) -> Graph {
        var size = Size2D(width: 0, height: lines.count)
        let map = lines.enumerated().reduce(into: [Point2D: Pipe](), { map, pair in
            let (y, line) = pair
            
            size.width = max(size.width, line.count)
            
            for (x, character) in line.enumerated() {
                guard let pipe = Pipe(rawValue: character) else {
                    continue
                }
                
                let point = Point2D(x: x, y: y)
                map[point] = pipe
            }
        })
        return Graph(map: map, size: size)
    }
    
    func part1(graph: Graph) -> (distance: Int, loop: [Point2D]) {
        let start = graph.map
            .first(where: { _, pipe in
                pipe == .startingPosition
            })!
            .key
        let loop = depthFirstSearch(from: start, to: start, graph: graph)
        
        return (loop.count / 2, loop)
    }
    
    func part2(graph: Graph, loop: [Point2D]) -> Int {
        // Based on OskarSigvardsson's Python solution
        // https://github.com/OskarSigvardsson/adventofcode/blob/master/2023/day10/day10.py
        
        let pointsInLoop = Set(loop)
        let rows = 0 ..< graph.size.height
        let columns = 0 ..< graph.size.width
        return rows.reduce(into: 0, { insideCount, y in
            for x in columns {
                let point = Point2D(x: x, y: y)
                
                if pointsInLoop.contains(point) {
                    continue
                }
                
                var crosses = 0
                var other = point
                
                while rows.contains(other.y), columns.contains(other.x) {
                    if pointsInLoop.contains(other),
                       graph.map[other] != .northEastBend,
                       graph.map[other] != .southWestBend {
                        crosses += 1
                    }
                    
                    other.x += 1
                    other.y += 1
                }
                
                if !crosses.isMultiple(of: 2) {
                    insideCount += 1
                }
            }
        })
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
            let neighbors = graph.adjacentPointsByPoint[current.point, default: []]
            
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
        let adjacentPointsByPoint: [Point2D: Set<Point2D>]
        let size: Size2D
        
        init(map: [Point2D: Pipe], size: Size2D) {
            self.map = map
            self.adjacentPointsByPoint = map.reduce(into: [:], { result, pair in
                let (point, pipe) = pair
                result[point] = pipe.connections(for: point).filter({ neighbor in
                    guard let neighboringPipe = map[neighbor] else {
                        return false
                    }
                    
                    return neighboringPipe.connections(for: neighbor).contains(point)
                })
            })
            self.size = size
        }
    }
}
