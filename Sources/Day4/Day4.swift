//
//  Day4.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-03.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

struct Day4: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day4",
            abstract: "Solve day 4 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let cards = try readLines().compactMap(Card.init)
        
        printTitle("Part 1", level: .title1)
        let totalPoints = part1(cards: cards)
        print("Total points:", totalPoints, terminator: "\n\n")
    }
    
    func part1(cards: [Card]) -> Int {
        let sum = cards.reduce(into: 0, { sum, card in
            sum += card.points()
        })
        return sum
    }
    
    struct Card {
        let id: Int
        let winningNumbers: [Int]
        let drawnNumbers: [Int]
        
        func drawnWinningNumberCount() -> Int {
            drawnNumbers.count(where: { winningNumbers.contains($0) })
        }
        
        func points() -> Int {
            let winningNumberCount = drawnWinningNumberCount()
            
            if winningNumberCount == 0 {
                return 0
            }
            
            return pow(2, winningNumberCount - 1)
        }
    }
}

extension Day4.Card {
    init?(rawValue: String) {
        let parts = rawValue.removingPrefix("Card").components(separatedBy: ": ")
        guard parts.count == 2 else {
            return nil
        }
        
        guard let id = Int(parts[0].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        
        let setsOfNumbers = parts[1].components(separatedBy: " | ")
        guard setsOfNumbers.count == 2 else {
            return nil
        }
        
        self.id = id
        self.winningNumbers = setsOfNumbers[0].split(whereSeparator: { $0 == " " }).compactMap({ Int(String($0)) })
        self.drawnNumbers = setsOfNumbers[1].split(whereSeparator: { $0 == " " }).compactMap({ Int(String($0)) })
    }
}

func pow(_ radix: Int, _ power: Int) -> Int {
    Int(pow(Double(radix), Double(power)))
}
