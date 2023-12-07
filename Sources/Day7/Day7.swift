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
        let totalWinningsWithFirstVariant = part1(hands: hands)
        print("Total winnings with first variant:", totalWinningsWithFirstVariant, terminator: "\n\n")
        
        let totalWinningsWithSecondVariant = part2(hands: hands)
        print("Total winnings with second variant:", totalWinningsWithSecondVariant)
    }
    
    func part1(hands: [Hand]) -> Int {
        let rule = FirstVariant()
        let sortedHands = hands.sorted(by: rule.areInIncreasingOrder)
        
        return sortedHands.enumerated().reduce(into: 0, { totalWinnings, pair in
            let (index, hand) = pair
            totalWinnings += (index + 1) * hand.bid
        })
    }
    
    func part2(hands: [Hand]) -> Int {
        let rule = SecondVariant()
        let sortedHands = hands.sorted(by: rule.areInIncreasingOrder)
        
        return sortedHands.enumerated().reduce(into: 0, { totalWinnings, pair in
            let (index, hand) = pair
            totalWinnings += (index + 1) * hand.bid
        })
    }
    
    struct Hand {
        typealias Card = Day7.Card
        
        let cards: [Card]
        let bid: Int
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
    
    private struct FirstVariant: Rule {
        func handType(for hand: Day7.Hand) -> Day7.HandType {
            let countsByCard: [Card: Int] = hand.cards.reduce(into: [:], { result, card in
                result[card, default: 0] += 1
            })
            let sortedCounts = Array(countsByCard.values).sorted(by: >)
            
            switch sortedCounts {
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
        
        func strength(of card: Day7.Card) -> Int {
            switch card {
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
    }
    
    private struct SecondVariant: Rule {
        func handType(for hand: Day7.Hand) -> Day7.HandType {
            var countsByCard: [Card: Int] = hand.cards.reduce(into: [:], { result, card in
                result[card, default: 0] += 1
            })
            let jokerCount = countsByCard[.labelJ, default: 0]
            if let highestNonJokerCountByCard = countsByCard
                .filter({ $0.key != .labelJ })
                .max(by: { $0.value < $1.value }), jokerCount > 0 {
                countsByCard[highestNonJokerCountByCard.key, default: 0] += jokerCount
                countsByCard.removeValue(forKey: .labelJ)
            }
            
            let sortedCounts = Array(countsByCard.values).sorted(by: >)
            switch sortedCounts {
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
        
        func strength(of card: Day7.Card) -> Int {
            switch card {
            case .labelA:
                12
            case .labelK:
                11
            case .labelQ:
                10
            case .labelT:
                9
            case .label9:
                8
            case .label8:
                7
            case .label7:
                6
            case .label6:
                5
            case .label5:
                4
            case .label4:
                3
            case .label3:
                2
            case .label2:
                1
            case .labelJ:
                0
            }
        }
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

private protocol Rule {
    func strength(of card: Day7.Card) -> Int
    func handType(for hand: Day7.Hand) -> Day7.HandType
}

extension Rule {
    func areInIncreasingOrder(_ lhs: Day7.Hand, _ rhs: Day7.Hand) -> Bool {
        let leftHandType = handType(for: lhs)
        let rightHandType = handType(for: rhs)
        
        if leftHandType < rightHandType {
            return true
        }
        
        if leftHandType > rightHandType {
            return false
        }
        
        for (leftCard, rightCard) in zip(lhs.cards, rhs.cards) {
            if leftCard == rightCard {
                continue
            }
            
            return leftCard < rightCard
        }
        
        return false
    }
}
