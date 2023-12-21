//
//  Day20.swift
//
//
//  Created by Marc-Antoine Malépart on 2023-12-19.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections

struct Day20: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day20",
            abstract: "Solve day 20 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let modulesByName = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let productOfLowAndHighPulses = part1(modulesByName: modulesByName)
        print(
            "Product of the total number of low pulses by the total number of high pulses:",
            productOfLowAndHighPulses,
            terminator: "\n\n"
        )
        
        printTitle("Part 2", level: .title1)
        printTitle("PlantUML", level: .title2)
        let plantUMLDiagram = plantUMLDiagram(modulesByName: modulesByName)
        print(plantUMLDiagram)
    }
    
    private func parse(_ lines: [String]) -> [String: CommunicationModuleVariant] {
        var modulesByName: [String: CommunicationModuleVariant] = lines
            .compactMap(CommunicationModuleVariant.init)
            .reduce(into: [:], { result, module in
                result[module.name] = module
            }
        )
        for (name, module) in modulesByName {
            for connection in module.outputConnections {
                modulesByName[connection]?.addInputConnection(name)
            }
        }
        
        return modulesByName
    }
    
    private func part1(modulesByName: [String: CommunicationModuleVariant]) -> Int {
        var modulesByName = modulesByName
        
        var sentCountsByPulse = [Pulse: Int]()
        
        for _ in 0 ..< 1_000 {
            var queue: Deque = [Signal(source: "button", pulse: .low, destination: "broadcaster")]
            
            while let signal = queue.popFirst() {
                sentCountsByPulse[signal.pulse, default: 0] += 1
                
                if signal.destination == "output" {
                    continue
                }
                
                guard var module = modulesByName[signal.destination] else {
                    continue
                }
                
                guard let output = module.process(signal.pulse, from: signal.source) else {
                    modulesByName[signal.destination] = module
                    continue
                }
                
                let moduleOutputs: [Signal] = module.outputConnections.map({ connection in
                    Signal(source: module.name, pulse: output, destination: connection)
                })
                
                queue.append(contentsOf: moduleOutputs)
                modulesByName[signal.destination] = module
            }
        }
        
        return sentCountsByPulse[.low, default: 0] * sentCountsByPulse[.high, default: 0]
    }
    
    private func plantUMLDiagram(modulesByName: [String: CommunicationModuleVariant]) -> String {
        var result = """
        @startuml
        hide empty members
        
        """
        
        let sortedModulesByName = modulesByName.sorted(by: { $0.key < $1.key })
        for (name, module) in sortedModulesByName {
            let definition = switch module {
            case .broadcast:
                "abstract \(name) << (B,lime) broadcast >>"
                
            case .conjunction:
                "class \(name) << (C,royalblue) conjunction >>"
                
            case .flipFlop:
                "interface \(name) << (F,orangered) flip flop >>"
            }
            
            result.append("\(definition)\n")
        }
        
        for (name, module) in sortedModulesByName {
            let outputs = module.outputConnections.sorted()
            
            for output in outputs {
                result.append("\(name) --> \(output)\n")
            }
        }
        
        result.append("@enduml")
        return result
    }
}

private enum CommunicationModuleVariant: CommunicationModule {
    case broadcast(BroadcastModule)
    case flipFlop(FlipFlopModule)
    case conjunction(ConjuctionModule)
    
    var name: String {
        switch self {
        case .broadcast(let module):
            module.name
        case .flipFlop(let module):
            module.name
        case .conjunction(let module):
            module.name
        }
    }
    
    var outputConnections: [String] {
        switch self {
        case .broadcast(let module):
            module.outputConnections
        case .flipFlop(let module):
            module.outputConnections
        case .conjunction(let module):
            module.outputConnections
        }
    }
    
    var inputConnections: Set<String> {
        get {
            switch self {
            case .broadcast(let module):
                module.inputConnections
            case .flipFlop(let module):
                module.inputConnections
            case .conjunction(let module):
                module.inputConnections
            }
        }
        set {
            switch self {
            case .broadcast(var module):
                module.inputConnections = newValue
                self = .broadcast(module)
                
            case .flipFlop(var module):
                module.inputConnections = newValue
                self = .flipFlop(module)
                
            case .conjunction(var module):
                module.inputConnections = newValue
                self = .conjunction(module)
            }
        }
    }
    
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse? {
        switch self {
        case .broadcast(let module):
            let result = module.process(pulse, from: input)
            self = .broadcast(module)
            return result
            
        case .flipFlop(var module):
            let result = module.process(pulse, from: input)
            self = .flipFlop(module)
            return result
            
        case .conjunction(var module):
            let result = module.process(pulse, from: input)
            self = .conjunction(module)
            return result
        }
    }
    
    mutating func addInputConnection(_ connection: String) {
        switch self {
        case .broadcast(var module):
            module.addInputConnection(connection)
            self = .broadcast(module)
            
        case .flipFlop(var module):
            module.addInputConnection(connection)
            self = .flipFlop(module)
            
        case .conjunction(var module):
            module.addInputConnection(connection)
            self = .conjunction(module)
        }
    }
}

extension CommunicationModuleVariant {
    init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: " -> ")
        guard parts.count == 2 else {
            return nil
        }
        
        let name = parts[0]
        switch name.first {
        case "%":
            guard let module = FlipFlopModule(rawValue: rawValue) else {
                return nil
            }
            
            self = .flipFlop(module)
            
        case "&":
            guard let module = ConjuctionModule(rawValue: rawValue) else {
                return nil
            }
            
            self = .conjunction(module)
            
        default:
            guard let module = BroadcastModule(rawValue: rawValue) else {
                return nil
            }
            
            self = .broadcast(module)
        }
    }
}

private struct BroadcastModule: CommunicationModule {
    let name: String
    let outputConnections: [String]
    var inputConnections: Set<String> = []
    
    func process(_ pulse: Pulse, from input: String) -> Pulse? {
        pulse
    }
}

extension BroadcastModule {
    init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: " -> ")
        guard parts.count == 2 else {
            return nil
        }
        
        self.name = parts[0]
        self.outputConnections = parts[1].components(separatedBy: ", ")
    }
}

private struct FlipFlopModule: CommunicationModule {
    let name: String
    let outputConnections: [String]
    var inputConnections: Set<String> = []
    
    var isOn = false
    
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse? {
        switch pulse {
        case .high:
            return nil
            
        case .low:
            let wasOn = isOn
            isOn.toggle()
            
            return if wasOn {
                .low
            }
            else {
                .high
            }
        }
    }
}

extension FlipFlopModule {
    init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: " -> ")
        guard parts.count == 2 else {
            return nil
        }
        
        self.name = parts[0].removingPrefix("%")
        self.outputConnections = parts[1].components(separatedBy: ", ")
    }
}

private struct ConjuctionModule: CommunicationModule {
    let name: String
    let outputConnections: [String]
    var inputConnections: Set<String> = []
    
    var lastPulseByInput = [String: Pulse]()
    
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse? {
        lastPulseByInput[input] = pulse
        
        let highPulseForAllInputs = inputConnections.allSatisfy({ lastPulseByInput[$0, default: .low] == .high })
        return if highPulseForAllInputs {
            .low
        }
        else {
            .high
        }
    }
}

extension ConjuctionModule {
    init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: " -> ")
        guard parts.count == 2 else {
            return nil
        }
        
        self.name = parts[0].removingPrefix("&")
        self.outputConnections = parts[1].components(separatedBy: ", ")
    }
}

private protocol CommunicationModule {
    var inputConnections: Set<String> { get set }
    var outputConnections: [String] { get }
    
    mutating func addInputConnection(_ connection: String)
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse?
}

extension CommunicationModule {
    mutating func addInputConnection(_ connection: String) {
        inputConnections.insert(connection)
    }
}

private enum Pulse {
    case low
    case high
}

private struct Signal {
    let source: String
    let pulse: Pulse
    let destination: String
}
