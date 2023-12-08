//
//  Day8.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-08.
//

import Foundation
import AdventOfCodeUtilities
import Algorithms
import ArgumentParser
import RegexBuilder

struct Day8: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day8",
            abstract: "Solve day 8 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (directions, map) = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let stepsToFinish = part1(directions: directions, map: map)
        print("How many steps are required to reach ZZZ?", stepsToFinish, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let stepsBeforeBeingOnlyOnNodesEndingWithZ = part2(directions: directions, map: map)
        print(
            "How many steps does it take before you're only on nodes that end with Z?",
            stepsBeforeBeingOnlyOnNodesEndingWithZ
        )
    }
    
    private func parse(_ lines: [String]) -> (directions: [Direction], map: [Node: Connection]) {
        let directions = lines[0].compactMap(Direction.init)
        
        let map: [Node: Connection] = lines.dropFirst(2).reduce(into: [:], { result, line in
            let components = line.components(separatedBy: " = ")
            
            guard components.count == 2 else {
                return
            }
            
            let node = Node(rawValue: components[0])
            
            guard let connection = Connection(rawValue: components[1]) else {
                return
            }
            
            result[node] = connection
        })
        
        return (directions, map)
    }
    
    func part1(directions: [Direction], map: [Node: Connection]) -> Int {
        steps(from: .start, toWhere: { $0 == .destination }, directions: directions, map: map)
    }
    
    private func steps(
        from start: Node,
        toWhere isDestination: @escaping (Node) -> Bool,
        directions: [Direction],
        map: [Node: Connection]
    ) -> Int {
        var steps = 0
        var current = start
        
        for direction in directions.cycled() {
            if isDestination(current) {
                break
            }
            
            let connection = map[current]!
            current = connection[keyPath: direction.keyPath]
            steps += 1
        }
        
        return steps
    }
    
    func part2(directions: [Direction], map: [Node: Connection]) -> Int {
        let nodesStartingWithA = map.keys.filter({ $0.rawValue.hasSuffix("A") })
        let stepsForAllNodes = nodesStartingWithA.map({ start -> Int in
            steps(from: start, toWhere: { $0.rawValue.hasSuffix("Z") }, directions: directions, map: map)
        })
        
        return stepsForAllNodes.reduce(into: 1, { result, steps in
            result = leastCommonMultiple(result, steps)
        })
    }
    
    struct Node: Hashable {
        let rawValue: String
        
        static let start = Node(rawValue: "AAA")
        static let destination = Node(rawValue: "ZZZ")
    }
    
    struct Connection {
        typealias Node = Day8.Node
        
        let leftNode: Node
        let rightNode: Node
    }
    
    enum Direction: Character {
        case left = "L"
        case right = "R"
        
        var keyPath: KeyPath<Connection, Node> {
            switch self {
            case .left:
                return \.leftNode
                
            case .right:
                return \.rightNode
            }
        }
    }
}

extension Day8.Connection {
    static let regex = Regex {
        "("
        
        Capture {
            OneOrMore(.word)
        }
        
        ", "
        
        Capture {
            OneOrMore(.word)
        }
        
        ")"
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        let (_, leftValue, rightValue) = match.output
        
        self.leftNode = Node(rawValue: String(leftValue))
        self.rightNode = Node(rawValue: String(rightValue))
    }
}

func greatestCommonDivisor(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

func leastCommonMultiple(_ x: Int, _ y: Int) -> Int {
    abs(x * y) / greatestCommonDivisor(x, y)
}
