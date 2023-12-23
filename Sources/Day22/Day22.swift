//
//  Day22.swift
//  
//
//  Created by Marc-Antoine Malépart on 2023-12-22.
//

import Foundation
import AdventOfCodeUtilities
import ArgumentParser
import Collections
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
        let bricks = parse(try readLines())
        
        printTitle("Part 1", level: .title1)
        let (numberOfDisintegratedBricks, pile) = part1(bricks: bricks)
        print("Number of safely disintegrated bricks:", numberOfDisintegratedBricks, terminator: "\n\n")
        
        printTitle("Part 2", level: .title1)
        let sumOfOtherFallingBricks = part2(pile: pile)
        print("What is the sum of the number of other bricks that would fall?", sumOfOtherFallingBricks)
    }
    
    private func parse(_ lines: [String]) -> [Brick] {
        let regex = Regex {
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
        
        return lines.enumerated().compactMap({ id, line in
            guard let match = line.firstMatch(of: regex) else {
                return nil
            }
            
            let start = Point3D(x: match.output.1, y: match.output.2, z: match.output.3)
            let end = Point3D(x: match.output.4, y: match.output.5, z: match.output.6)
            return Brick(id: id, start: start, end: end)
        })
    }
    
    private func part1(bricks: [Brick]) -> (result: Int, pile: Pile) {
        var pile = Pile()
        var bricksByZ = [Int: Set<Brick>]()
    
        for brick in bricks.sorted(by: { $0.start.z < $1.start.z }) {
            let zCandidates = 1 ..< brick.start.z
            
            var previousZ = 0
            var supports = Set<Brick>()
            for z in zCandidates.sorted(by: >) {
                guard let bricksAtZ = bricksByZ[z] else {
                    continue
                }
                
                supports = bricksAtZ.filter({ placedBrick in
                    return placedBrick.xRange.overlaps(brick.xRange) && placedBrick.yRange.overlaps(brick.yRange)
                })
                
                if !supports.isEmpty {
                    previousZ = z
                    break
                }
            }
        
            let translation = Translation3D(deltaX: 0, deltaY: 0, deltaZ: previousZ - brick.start.z + 1)
            let translated = brick.applying(translation)
            pile.placeBrick(translated, supportedBy: supports)
            
            translated.zRange.forEach({ z in
                bricksByZ[z, default: []].insert(translated)
            })
        }
        
        let result = pile.bricks.count(where: { brick in
            let dependants = pile.dependants(for: brick)
            
            if dependants.isEmpty {
                return true
            }
            
            return dependants.allSatisfy({ dependant in
                pile.supports(for: dependant).count >= 2
            })
        })
        return (result, pile)
    }
    
    private func part2(pile: Pile) -> Int {
        pile.bricks.reduce(into: 0, { sum, brick in
            var pile = pile
            var fallenBricks = Set<Brick>()
            var queue: Deque<Brick> = [brick]
            
            while let current = queue.popFirst() {
                let dependants = pile.dependants(for: current)
                
                pile.removeBrick(current)
                fallenBricks.insert(current)
                
                for dependant in dependants {
                    let supports = pile.supports(for: dependant)
                    
                    if !fallenBricks.contains(dependant), supports.isEmpty {
                        queue.append(dependant)
                    }
                }
            }
            
            sum += fallenBricks.subtracting([brick]).count
        })
    }
}

private struct Pile {
    var bricks = Set<Brick>()
    var dependantBricksByBrick = [Brick: Set<Brick>]()
    var supportingBricksByBrick = [Brick: Set<Brick>]()
    
    func supports(for brick: Brick) -> Set<Brick> {
        supportingBricksByBrick[brick, default: []]
    }
    
    func dependants(for brick: Brick) -> Set<Brick> {
        dependantBricksByBrick[brick, default: []]
    }
    
    mutating func placeBrick(_ brick: Brick, supportedBy supports: Set<Brick>) {
        bricks.insert(brick)
        supportingBricksByBrick[brick] = supports
        for support in supports {
            dependantBricksByBrick[support, default: []].insert(brick)
        }
    }
    
    mutating func removeBrick(_ brick: Brick) {
        bricks.remove(brick)
        
        let dependants = dependants(for: brick)
        for dependant in dependants {
            supportingBricksByBrick[dependant, default: []].remove(brick)
        }
        dependantBricksByBrick.removeValue(forKey: brick)
        
        let supports = supports(for: brick)
        for support in supports {
            dependantBricksByBrick[support, default: []].remove(brick)
        }
        supportingBricksByBrick.removeValue(forKey: brick)
    }
}

private struct Brick: Hashable {
    let id: Int
    let start: Point3D
    let end: Point3D
    
    var xRange: ClosedRange<Int> { start.x ... end.x }
    var yRange: ClosedRange<Int> { start.y ... end.y }
    var zRange: ClosedRange<Int> { start.z ... end.z }
    
    func overlaps(_ other: Brick) -> Bool {
        xRange.overlaps(other.xRange) && yRange.overlaps(other.yRange) && zRange.overlaps(other.zRange)
    }
    
    func applying(_ translation: Translation3D) -> Self {
        Self(
            id: id,
            start: start.applying(translation),
            end: end.applying(translation)
        )
    }
}
