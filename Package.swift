// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GitReposMonitor",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "GitReposMonitor",
            path: "Sources/GitReposMonitor"
        )
    ]
)
