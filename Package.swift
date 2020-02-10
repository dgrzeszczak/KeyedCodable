// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeyedCodable",
    platforms: [.macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)],
    products: [
        .library(name: "KeyedCodable",
                 targets: ["KeyedCodable-iOS",
                    "KeyedCodable-watchOS",
                    "KeyedCodable-tvOS",
                    "KeyedCodable-macOS"]
        ),
    ],
    targets: [
        .target(name: "KeyedCodable-iOS"),
        .target(name: "KeyedCodable-watchOS"),
        .target(name: "KeyedCodable-tvOS"),
        .target(name: "KeyedCodable-macOS")
    ]
)
