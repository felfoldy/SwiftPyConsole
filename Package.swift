// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPyConsole",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SwiftPyConsole",
                 targets: ["SwiftPyConsole"]),
    ],
    dependencies: [
        .package(url: "https://github.com/felfoldy/SwiftPy", from: "0.2.0"),
        .package(url: "https://github.com/felfoldy/DebugTools", from: "0.4.0"),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.2.1"),
    ],
    targets: [
        .target(name: "SwiftPyConsole",
                dependencies: ["SwiftPy",
                               "DebugTools",
                               "Highlightr"]),
        .testTarget(
            name: "SwiftPyConsoleTests",
            dependencies: ["SwiftPyConsole"]
        ),
    ]
)
