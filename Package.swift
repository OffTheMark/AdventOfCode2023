// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode2023",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "aoc2023",
            targets: ["AdventOfCode2023"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/OffTheMark/AdventOfCodeUtilities.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode2023",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AdventOfCodeUtilities", package: "AdventOfCodeUtilities"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
    ]
)
