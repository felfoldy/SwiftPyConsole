// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPyConsole",
    platforms: [.macOS(.v26), .iOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "SwiftPyConsole",
                 targets: ["SwiftPyConsole"]),
    ],
    dependencies: [
        .package(url: "https://github.com/felfoldy/SwiftPy", from: "0.9.0"),
        .package(url: "https://github.com/felfoldy/DebugTools", from: "0.5.0"),
        .package(url: "https://github.com/appstefan/HighlightSwift.git", from: "1.1.0")
    ],
    targets: [
        .target(name: "SwiftPyConsole",
                dependencies: ["SwiftPy",
                               "DebugTools",
                               "HighlightSwift"]),
        .testTarget(
            name: "SwiftPyConsoleTests",
            dependencies: ["SwiftPyConsole"]
        ),
    ]
)
