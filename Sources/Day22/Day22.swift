//
//  Day22.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-22.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import RegexBuilder

struct Day22: DayCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "day22",
            abstract: "Solve day 22 puzzle"
        )
    }
    
    @Argument(help: "Puzzle input path")
    var puzzleInputPath: String
    
    func run() throws {
        let bricks = try readLines().compactMap(Brick.init)
        
        printTitle("Part 1", level: .title1)
        let numberOfDisintegratedBricks = part1(bricks: bricks)
        print("Number of safely disintegrated bricks:", numberOfDisintegratedBricks, terminator: "\n\n")
    }
    
    private func part1(bricks: [Brick]) -> Int {
        var placedBricksByID = [Int: Brick]()
        var bricksByZ = [Int: Set<Int>]()
        var supportingBricksByID = [Int: Set<Int>]()
        var dependantBricksByID = [Int: Set<Int>]()
        
        func placeBrick(_ brick: Brick, withID id: Int) {
            placedBricksByID[id] = brick
            brick.zRange.forEach({ z in
                bricksByZ[z, default: []].insert(id)
            })
        }
        
        for (id, brick) in bricks.enumerated().sorted(by: { $0.element.start.z < $1.element.start.z }) {
            let zCandidates = 1 ..< brick.start.z
            
            var previousZ = 0
            var supports = Set<Int>()
            for z in zCandidates.sorted(by: >) {
                guard let bricksAtZ = bricksByZ[z] else {
                    continue
                }
                
                supports = bricksAtZ.filter({ id in
                    let placedBrick = placedBricksByID[id]!
                    return placedBrick.xRange.overlaps(brick.xRange) && placedBrick.yRange.overlaps(brick.yRange)
                })
                
                if !supports.isEmpty {
                    previousZ = z
                    break
                }
            }
        
            let translation = Translation3D(deltaX: 0, deltaY: 0, deltaZ: previousZ - brick.start.z + 1)
            let translated = brick.applying(translation)
            placedBricksByID[id] = translated
            translated.zRange.forEach({ z in
                bricksByZ[z, default: []].insert(id)
            })
            
            supportingBricksByID[id, default: []].formUnion(supports)
            
            for support in supports {
                dependantBricksByID[support, default: []].insert(id)
            }
        }
        
        return placedBricksByID.keys.count(where: { currentID in
            let dependants = dependantBricksByID[currentID, default: []]
            if dependants.isEmpty {
                return true
            }
            
            return dependants.allSatisfy({ dependantID in
                let supportingBricks = supportingBricksByID[dependantID, default: []]
                return supportingBricks.count >= 2
            })
        })
    }
}

private struct Brick {
    let start: Point3D
    let end: Point3D
    
    var xRange: ClosedRange<Int> { start.x ... end.x }
    var yRange: ClosedRange<Int> { start.y ... end.y }
    var zRange: ClosedRange<Int> { start.z ... end.z }
    
    func overlaps(_ other: Brick) -> Bool {
        xRange.overlaps(other.xRange) && yRange.overlaps(other.yRange) && zRange.overlaps(other.zRange)
    }
    
    func applying(_ translation: Translation3D) -> Self {
        Self(start: start.applying(translation), end: end.applying(translation))
    }
}

extension Brick {
    static let regex = Regex {
        let number = TryCapture {
            OneOrMore(.digit)
        } transform: {
            Int(String($0))
        }
        
        number
        ","
        number
        ","
        number
        "~"
        number
        ","
        number
        ","
        number
    }
    
    init?(rawValue: String) {
        guard let match = rawValue.firstMatch(of: Self.regex) else {
            return nil
        }
        
        self.start = Point3D(x: match.output.1, y: match.output.2, z: match.output.3)
        self.end = Point3D(x: match.output.4, y: match.output.5, z: match.output.6)
    }
}
