//
//  Day19.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-18.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections
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
        
        printTitle("Part 2", level: .title1)
        let numberOfDistinctAcceptedCombinations = part2(workflows: workflows)
        print("Number of distinct combinations of accepted ratings:", numberOfDistinctAcceptedCombinations)
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
            var currentDestination: Destination = .workflow("in")
            
            while case .workflow(let workflowName) = currentDestination {
                let workflow = workflowsByName[workflowName]!
                
                currentDestination = workflow.destination(for: part)
            }
            
            return currentDestination == .accepted
        })
        
        return acceptedParts.reduce(into: 0, { sum, part in
            sum += part.extremelyCoolLooking + part.musical + part.aerodynamic + part.shiny
        })
    }
    
    func part2(workflows: [Workflow]) -> Int {
        let workflowsByName: [String: Workflow] = workflows.reduce(into: [:], { result, workflow in
            result[workflow.name] = workflow
        })
        let inputWorkflow = workflowsByName["in"]!
        
        return numberOfMatchingRanges(
            combination: PartCategoryCombination(),
            workflow: inputWorkflow,
            workflowsByName: workflowsByName
        )
    }
    
    private func numberOfMatchingRanges(
        combination: PartCategoryCombination,
        workflow: Workflow,
        workflowsByName: [String: Workflow]
    ) -> Int {
        var result = 0
        
        var combination = combination
        for rule in workflow.rules {
            let condition = rule.condition
            let keyPath = condition.combinationKeyPath
            let currentRange = combination[keyPath: keyPath]
            
            if let positiveIntersection = currentRange.intersection(condition.positiveRange) {
                var neighbor = combination
                neighbor[keyPath: keyPath] = positiveIntersection
                
                let addedRanges = switch rule.destination {
                case .accepted:
                    neighbor.count
                case .rejected:
                    0
                case .workflow(let workflowName):
                    numberOfMatchingRanges(
                        combination: neighbor,
                        workflow: workflowsByName[workflowName]!,
                        workflowsByName: workflowsByName
                    )
                }
                result += addedRanges
            }
            
            guard let negativeIntersection = currentRange.intersection(condition.negativeRange) else {
                break
            }
            
            combination[keyPath: keyPath] = negativeIntersection
        }
        
        let addedRanges = switch workflow.finalDestination {
        case .accepted:
            combination.count
        case .rejected:
            0
        case .workflow(let workflowName):
            numberOfMatchingRanges(
                combination: combination,
                workflow: workflowsByName[workflowName]!,
                workflowsByName: workflowsByName
            )
        }
        result += addedRanges
        
        return result
    }
        
    struct Part {
        let extremelyCoolLooking: Int
        let musical: Int
        let aerodynamic: Int
        let shiny: Int
    }
    
    struct Workflow {
        typealias Rule = Day19.Rule
        typealias Destination = Day19.Destination
        
        let name: String
        let rules: [Rule]
        let finalDestination: Destination
        
        func destination(for part: Part) -> Destination {
            rules.first(where: { $0.condition.matches(part) })?.destination ?? finalDestination
        }
    }
    
    struct Rule {
        typealias Condition = Day19.Condition
        typealias Destination = Day19.Destination
        
        let condition: Condition
        let destination: Destination
    }
    
    struct Condition {
        typealias Category = Day19.Category
        typealias Rating = Day19.Part
        typealias Comparison = Day19.Comparison
        
        let category: Category
        let comparison: Comparison
        let value: Int
        
        var combinationKeyPath: WritableKeyPath<PartCategoryCombination, ClosedRange<Int>> {
            category.combinationKeyPath
        }
        
        var positiveRange: ClosedRange<Int> {
            switch comparison {
            case .lessThan:
                1 ... (value - 1)
                
            case .greaterThan:
                (value + 1) ... 4_000
            }
        }
        
        var negativeRange: ClosedRange<Int> {
            switch comparison {
            case .lessThan:
                value ... 4_000
                
            case .greaterThan:
                1 ... value
            }
        }
    
        
        func matches(_ rating: Rating) -> Bool {
            comparison.compare(rating[keyPath: category.partKeyPath], value)
        }
    }
    
    struct PartCategoryCombination: Hashable {
        var extremelyCoolLooking: ClosedRange<Int> = 1 ... 4_000
        var musical: ClosedRange<Int> = 1 ... 4_000
        var aerodynamic: ClosedRange<Int> = 1 ... 4_000
        var shiny: ClosedRange<Int> = 1 ... 4_000
        
        var count: Int {
            let keyPaths: [KeyPath<Self, Int>] = [
                \.extremelyCoolLooking.count,
                \.musical.count,
                \.aerodynamic.count,
                \.shiny.count
            ]
            return keyPaths.reduce(into: 1, { product, keyPath in
                product *= self[keyPath: keyPath]
            })
        }
    }
    
    enum Category: Character {
        case extremelyCoolLooking = "x"
        case musical = "m"
        case aerodynamic = "a"
        case shiny = "s"
        
        var partKeyPath: KeyPath<Part, Int> {
            switch self {
            case .extremelyCoolLooking:
                \.extremelyCoolLooking
            case .musical:
                \.musical
            case .aerodynamic:
                \.aerodynamic
            case .shiny:
                \.shiny
            }
        }
        
        var combinationKeyPath: WritableKeyPath<PartCategoryCombination, ClosedRange<Int>> {
            switch self {
            case .extremelyCoolLooking:
                \.extremelyCoolLooking
            case .musical:
                \.musical
            case .aerodynamic:
                \.aerodynamic
            case .shiny:
                \.shiny
            }
        }
    }
    
    enum Comparison: Character {
        case lessThan = "<"
        case greaterThan = ">"
        
        var compare: (Int, Int) -> Bool {
            switch self {
            case .lessThan:
                (<)
                
            case .greaterThan:
                (>)
            }
        }
    }
    
     enum Destination: Equatable {
        case accepted
        case rejected
        case workflow(String)
        
        init(rawValue: String) {
            switch rawValue {
            case "A":
                self = .accepted
                
            case "R":
                self = .rejected
                
            default:
                self = .workflow(rawValue)
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
        self.finalDestination = Destination(rawValue: ruleComponents.last!)
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
        self.destination = Destination(rawValue: components[1])
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
        } transform: { substring -> Category? in
            substring.first.flatMap(Category.init)
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
        
        self.category = match.output.1
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

extension Range {
    func intersection(_ other: Range<Bound>) -> Range<Bound>? {
        let maximumLowerBound = Swift.max(lowerBound, other.lowerBound)
        let minimumUpperBound = Swift.min(upperBound, other.upperBound)
        
        let lowerBeforeUpper = maximumLowerBound <= upperBound && maximumLowerBound < other.upperBound
        let upperBeforeLower = minimumUpperBound >= lowerBound && minimumUpperBound >= other.lowerBound
        
        guard lowerBeforeUpper, upperBeforeLower else {
            return nil
        }
        
        return maximumLowerBound ..< minimumUpperBound
    }
}

extension ClosedRange {
    func intersection(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let maximumLowerBound = Swift.max(lowerBound, other.lowerBound)
        let minimumUpperBound = Swift.min(upperBound, other.upperBound)
        
        let lowerBeforeUpper = maximumLowerBound <= upperBound && maximumLowerBound < other.upperBound
        let upperBeforeLower = minimumUpperBound >= lowerBound && minimumUpperBound >= other.lowerBound
        
        guard lowerBeforeUpper, upperBeforeLower else {
            return nil
        }
        
        return maximumLowerBound ... minimumUpperBound
    }
}
