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
        let modulesByName: [String: CommunicationModuleVariant] = try readLines()
            .compactMap(CommunicationModuleVariant.init)
            .reduce(into: [:], { result, module in
                result[module.name] = module
            }
        )
        
        printTitle("Part 1", level: .title1)
        let productOfLowAndHighPulses = part1(modulesByName: modulesByName)
        print(
            "Product of the total number of low pulses by the total number of high pulses:",
            productOfLowAndHighPulses,
            terminator: "\n\n"
        )
    }
    
    private func part1(modulesByName: [String: CommunicationModuleVariant]) -> Int {
        var modulesByName = modulesByName
        
        struct Input {
            let source: String
            let pulse: Pulse
            let connection: String
        }
        var sentCountsByPulse = [Pulse: Int]()
        
        for _ in 0 ..< 1_000 {
            var queue: Deque = [Input(source: "button", pulse: .low, connection: "broadcaster")]
            
            while let input = queue.popFirst() {
                sentCountsByPulse[input.pulse, default: 0] += 1
                
                if input.connection == "output" {
                    continue
                }
                
                guard var module = modulesByName[input.connection] else {
                    continue
                }
                
                guard let output = module.process(input.pulse, from: input.source) else {
                    modulesByName[input.connection] = module
                    continue
                }
                
                let moduleOutputs: [Input] = module.connections.map({ connection in
                    Input(source: module.name, pulse: output, connection: connection)
                })
                
                queue.append(contentsOf: moduleOutputs)
                modulesByName[input.connection] = module
            }
        }
        
        return sentCountsByPulse[.low, default: 0] * sentCountsByPulse[.high, default: 0]
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
    
    var connections: [String] {
        switch self {
        case .broadcast(let module):
            module.connections
        case .flipFlop(let module):
            module.connections
        case .conjunction(let module):
            module.connections
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
    let connections: [String]
    
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
        self.connections = parts[1].components(separatedBy: ", ").map({ $0.removingPrefix("%").removingPrefix("&") })
    }
}

private struct FlipFlopModule: CommunicationModule {
    let name: String
    let connections: [String]
    
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
        self.connections = parts[1].components(separatedBy: ", ").map({ $0.removingPrefix("%").removingPrefix("&") })
    }
}

private struct ConjuctionModule: CommunicationModule {
    let name: String
    let connections: [String]
    
    var lastPulseByInput = [String: Pulse]()
    
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse? {
        lastPulseByInput[input] = pulse
        
        let highPulseForAllInputs = lastPulseByInput.allSatisfy({ $0.value == .high })
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
        self.connections = parts[1].components(separatedBy: ", ").map({ $0.removingPrefix("%").removingPrefix("&") })
    }
}

private protocol CommunicationModule {
    var connections: [String] { get }
    
    mutating func process(_ pulse: Pulse, from input: String) -> Pulse?
}

private enum Pulse {
    case low
    case high
}
