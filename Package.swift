// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftlyImageLoader",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftlyImageLoader",
            targets: ["SwiftlyImageLoader"]
        ),
        .library(
            name: "SwiftlyImageLoaderUIKit",
            targets: ["SwiftlyImageLoaderUIKit"]
        ),
        .library(
            name: "SwiftlyImageLoaderAppKit",
            targets: ["SwiftlyImageLoaderAppKit"]
        ),
        .library(
            name: "SwiftlyImageLoaderSwiftUI",
            targets: ["SwiftlyImageLoaderSwiftUI"]
        )
    ],
    targets: [
        .target(
            name: "SwiftlyImageLoader",
            path: "Sources/SwiftlyImageLoader"
        ),
        .target(
            name: "SwiftlyImageLoaderUIKit",
            dependencies: ["SwiftlyImageLoader"],
            path: "Sources/SwiftlyImageLoaderUIKit"
        ),
        .target(
            name: "SwiftlyImageLoaderAppKit",
            dependencies: ["SwiftlyImageLoader"],
            path: "Sources/SwiftlyImageLoaderAppKit"
        ),
        .target(
            name: "SwiftlyImageLoaderSwiftUI",
            dependencies: ["SwiftlyImageLoader"],
            path: "Sources/SwiftlyImageLoaderSwiftUI"
        )
    ]
)
