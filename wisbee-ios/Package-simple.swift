// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Wisbee",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        // Simpler approach - just use URLSession for Ollama API
    ],
    targets: [
        .executableTarget(
            name: "Wisbee",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)