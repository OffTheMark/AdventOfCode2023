//
//  Day2.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import RegexBuilder

struct Day2: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day2",
            abstract: "Solve day 2 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let games = try readLines().compactMap(Game.init)
        
        printTitle("Part 1", level: .title1)
        let sumOfIDs = part1(games: games)
        print("Sum of IDs:", sumOfIDs, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfPowers = part2(games: games)
        print("Sum of powers:", sumOfPowers)
    }
    
    fileprivate func part1(games: [Game]) -> Int {
        let possiblesContentsOfBag: [CubeColor: Int] = [
            .red: 12,
            .green: 13,
            .blue: 14
        ]
        
        return games.reduce(into: 0, { sum, game in
            guard game.isPossible(with: possiblesContentsOfBag) else {
                return
            }
            
            sum += game.id
        })
    }
    
    fileprivate func part2(games: [Game]) -> Int {
        return games.reduce(into: 0, { sum, game in
            let minimumCountPerColor = game.minimumCountPerColor()
            let power = minimumCountPerColor.values.reduce(1, *)
            sum += power
        })
    }
}

private struct Game {
    let id: Int
    let turns: [Turn]
    
    func isPossible(with countPerColor: [CubeColor: Int]) -> Bool {
        turns.allSatisfy({ turn in
            countPerColor.allSatisfy({ color, count in
                turn.countPerColor[color, default: 0] <= count
            })
        })
    }
    
    func minimumCountPerColor() -> [CubeColor: Int] {
        turns.reduce(into: [CubeColor: Int](), { result, turn in
            result.merge(turn.countPerColor, uniquingKeysWith: { left, right in
                max(left, right)
            })
        })
    }
}

extension Game {
    init?(rawValue: String) {
        let parts = rawValue.removingPrefix("Game ").components(separatedBy: ": ")
        
        guard parts.count == 2 else {
            return nil
        }
        
        guard let id = Int(parts[0]) else {
            return nil
        }
        
        self.id = id
        self.turns = parts[1].components(separatedBy: "; ").compactMap(Turn.init)
    }
}

private struct Turn {
    let countPerColor: [CubeColor: Int]
}

extension Turn {
    init?(rawValue: String) {
        let draws = rawValue.components(separatedBy: ", ")
        
        var countPerColor = [CubeColor: Int]()
        for draw in draws {
            let parts = draw.components(separatedBy: " ")
            
            guard parts.count == 2 else {
                return nil
            }
            
            guard let count = Int(parts[0]) else {
                return nil
            }
            
            guard let color = CubeColor(rawValue: parts[1]) else {
                return nil
            }
            
            countPerColor[color] = count
        }
        
        self.countPerColor = countPerColor
    }
}

private enum CubeColor: String {
    case red
    case green
    case blue
}

extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        
        return String(dropFirst(prefix.count))
    }
}
