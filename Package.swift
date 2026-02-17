// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Scrawl",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Scrawl",
            path: "Sources/Scrawl",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ScrawlTests",
            dependencies: ["Scrawl"],
            path: "Tests/ScrawlTests"
        )
    ]
)
