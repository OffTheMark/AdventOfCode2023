//
//  Day7.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-07.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import RegexBuilder

struct Day7: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day7",
            abstract: "Solve day 7 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let hands = try readLines().compactMap(Hand.init)
        
        printTitle("Part 1", level: .title1)
        let totalWinnings = part1(hands: hands)
        print("Total winnings:", totalWinnings, terminator: "\n\n")
    }
    
    func part1(hands: [Hand]) -> Int {
        let sortedHands = hands.sorted(by: { left, right in
            let leftHandType = left.handType()
            let rightHandType = right.handType()
            
            if leftHandType < rightHandType {
                return true
            }
            
            if leftHandType > rightHandType {
                return false
            }
            
            for (leftCard, rightCard) in zip(left.cards, right.cards) {
                if leftCard == rightCard {
                    continue
                }
                
                return leftCard < rightCard
            }
            
            return false
        })
        
        return sortedHands.enumerated().reduce(into: 0, { totalWinnings, pair in
            let (index, hand) = pair
            totalWinnings += (index + 1) * hand.bid
        })
    }
    
    struct Hand {
        typealias Card = Day7.Card
        
        let cards: [Card]
        let bid: Int
        
        func handType() -> HandType {
            let countsByCard: [Card: Int] = cards.reduce(into: [:], { result, card in
                result[card, default: 0] += 1
            })
            let orderedCounts = Array(countsByCard.values).sorted(by: >)
            
            switch orderedCounts {
            case [5]:
                return .fiveOfAKind
                
            case [4, 1]:
                return .fourOfAKind
                
            case [3, 2]:
                return .fullHouse
                
            case [3, 1, 1]:
                return .threeOfAKind
                
            case [2, 2, 1]:
                return .twoPairs
                
            case [2, 1, 1, 1]:
                return .onePair
                
            default:
                return .highCard
            }
        }
    }
    
    enum Card: Character, Comparable {
        case labelA = "A"
        case labelK = "K"
        case labelQ = "Q"
        case labelJ = "J"
        case labelT = "T"
        case label9 = "9"
        case label8 = "8"
        case label7 = "7"
        case label6 = "6"
        case label5 = "5"
        case label4 = "4"
        case label3 = "3"
        case label2 = "2"
    }
    
    enum HandType: Hashable, Comparable {
        case fiveOfAKind
        case fourOfAKind
        case fullHouse
        case threeOfAKind
        case twoPairs
        case onePair
        case highCard
    }
}

extension Day7.Hand {
    static let regex = Regex {
        Capture {
            OneOrMore(.any)
        }
        
        " "
        
        TryCapture {
            OneOrMore(.digit)
        } transform: { rawValue in
            Int(String(rawValue))
        }
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        let (_, cards, bid) = match.output
        
        self.cards = cards.compactMap(Card.init)
        self.bid = bid
    }
}

extension Day7.Card {
    private var order: Int {
        switch self {
        case .labelA:
            12
        case .labelK:
            11
        case .labelQ:
            10
        case .labelJ:
            9
        case .labelT:
            8
        case .label9:
            7
        case .label8:
            6
        case .label7:
            5
        case .label6:
            4
        case .label5:
            3
        case .label4:
            2
        case .label3:
            1
        case .label2:
            0
        }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        rhs.order <= lhs.order
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.order > rhs.order
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.order >= rhs.order
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.order == rhs.order
    }
}

extension Day7.HandType {
    private var order: Int {
        switch self {
        case .fiveOfAKind:
            6
        case .fourOfAKind:
            5
        case .fullHouse:
            4
        case .threeOfAKind:
            3
        case .twoPairs:
            2
        case .onePair:
            1
        case .highCard:
            0
        }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        rhs.order <= lhs.order
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.order > rhs.order
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.order >= rhs.order
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.order == rhs.order
    }
}
