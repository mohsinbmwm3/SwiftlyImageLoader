// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftlyImageLoader",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftlyImageLoader",
            targets: ["SwiftlyImageLoader"]),
    ],
    targets: [
        .target(
            name: "SwiftlyImageLoader",
            path: "Sources/SwiftlyImageLoader")
    ]
)
