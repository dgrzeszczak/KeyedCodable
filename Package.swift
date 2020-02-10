// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// TODO: resolve problem with sources shared to all targets

let package = Package(
    name: "KeyedCodable",
//    platforms: [.macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)],
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "KeyedCodable",
//            targets: ["KeyedCodable-iOS", "KeyedCodable-watchOS", "KeyedCodable-tvOS", "KeyedCodable-macOS"]
            targets: ["KeyedCodable-iOS"]
        ),
    ],
    targets: [
        .target(name: "KeyedCodable-iOS", path: "KeyedCodable/Sources"),
//        .target(name: "KeyedCodable-watchOS", path: "KeyedCodable/Sources"),
//        .target(name: "KeyedCodable-tvOS", path: "KeyedCodable/Sources"),
//        .target(name: "KeyedCodable-macOS", path: "KeyedCodable/Sources")
    ]
)
