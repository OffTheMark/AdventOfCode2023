//
//  Day19.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-18.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import RegexBuilder

struct Day19: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day19",
            abstract: "Solve day 19 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let (workflows, parts) = parse(try readFile())!
        
        printTitle("Part 1", level: .title1)
        let sumOfRatingNumbers = part1(workflows: workflows, parts: parts)
        print("Sum of rating numbers of accepted parts:", sumOfRatingNumbers, terminator: "\n\n")
    }
    
    private func parse(_ input: String) -> (workflows: [Workflow], parts: [Part])? {
        let components = input.components(separatedBy: "\n\n")
        guard components.count == 2 else {
            return nil
        }
        
        let workflows = components[0].components(separatedBy: .newlines).compactMap(Workflow.init)
        let parts = components[1].components(separatedBy: .newlines).compactMap(Part.init)
        
        return (workflows, parts)
    }
    
    func part1(workflows: [Workflow], parts: [Part]) -> Int {
        let workflowsByName: [String: Workflow] = workflows.reduce(into: [:], { result, workflow in
            result[workflow.name] = workflow
        })
        
        let acceptedParts = parts.filter({ part in
            var currentDestination = "in"
            
            while !["A", "R"].contains(currentDestination) {
                guard let workflow = workflowsByName[currentDestination] else {
                    return false
                }
                
                currentDestination = workflow.destination(for: part)
            }
            
            return currentDestination == "A"
        })
        
        return acceptedParts.reduce(into: 0, { sum, part in
            sum += part.extremelyCoolLooking + part.musical + part.aerodynamic + part.shiny
        })
    }
        
    struct Part: Decodable {
        let extremelyCoolLooking: Int
        let musical: Int
        let aerodynamic: Int
        let shiny: Int
        
        enum CodingKeys: String, CodingKey {
            case extremelyCoolLooking = "x"
            case musical = "m"
            case aerodynamic = "a"
            case shiny = "s"
        }
    }
    
    struct Workflow {
        typealias Rule = Day19.Rule
        
        let name: String
        let rules: [Rule]
        let finalDestination: String
        
        func destination(for part: Part) -> String {
            rules.first(where: { $0.condition.matches(part) })?.destination ?? finalDestination
        }
    }
    
    struct Rule {
        typealias Condition = Day19.Condition
        
        let condition: Condition
        let destination: String
    }
    
    struct Condition {
        typealias Rating = Day19.Part
        typealias Comparison = Day19.Comparison
        
        let keyPath: KeyPath<Rating, Int>
        let comparison: Comparison
        let value: Int
        
        func matches(_ rating: Rating) -> Bool {
            comparison.compare(rating[keyPath: keyPath], value)
        }
    }
    
    enum Comparison: Character {
        case lessThan = "<"
        case greaterThan = ">"
        
        func compare(_ lhs: Int, _ rhs: Int) -> Bool {
            switch self {
            case .lessThan:
                lhs < rhs
                
            case .greaterThan:
                lhs > rhs
            }
        }
    }
}

extension Day19.Workflow {
    init?(rawValue: String) {
        let parts = rawValue.removingSuffix("}").components(separatedBy: "{")
        
        guard parts.count == 2 else {
            return nil
        }
        
        let ruleComponents = parts[1].components(separatedBy: ",")
        
        if ruleComponents.isEmpty {
            return nil
        }
        
        self.name = parts[0]
        self.rules = ruleComponents.dropLast().compactMap(Rule.init)
        self.finalDestination = ruleComponents.last!
    }
}

extension Day19.Rule {
    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: ":")
        
        guard components.count == 2 else {
            return nil
        }
        
        guard let condition = Condition(rawValue: components[0]) else {
            return nil
        }
        
        self.condition = condition
        self.destination = components[1]
    }
}

extension Day19.Condition {
    static let regex = Regex {
        TryCapture {
            ChoiceOf {
                "x"
                "m"
                "a"
                "s"
            }
        } transform: { substring -> KeyPath<Rating, Int>? in
            switch substring {
            case "x":
                return \.extremelyCoolLooking
                
            case "m":
                return \.musical
            
            case "a":
                return \.aerodynamic
                
            case "s":
                return \.shiny
                
            default:
                return nil
            }
        }
        
        TryCapture {
            ChoiceOf {
                "<"
                ">"
            }
        } transform: { substring -> Comparison? in
            substring.first.flatMap({ Comparison(rawValue: $0) })
        }
        
        TryCapture {
            OneOrMore(.digit)
        } transform: { value in
            Int(String(value))
        }
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        self.keyPath = match.output.1
        self.comparison = match.output.2
        self.value = match.output.3
    }
}

extension Day19.Part {
    static let regex = Regex {
        "{x="
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        ",m="
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        ",a="
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        ",s="
        
        TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        "}"
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        self.extremelyCoolLooking = match.output.1
        self.musical = match.output.2
        self.aerodynamic = match.output.3
        self.shiny = match.output.4
    }
}

extension String {
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }
        
        return String(dropLast(suffix.count))
    }
}
