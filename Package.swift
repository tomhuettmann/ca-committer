// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ca-committer",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "ca-committer",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftTUI", package: "SwiftTUI"),
            ],
            path: "Sources"
        ),
    ]
)
