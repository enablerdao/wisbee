// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Wisbee",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    dependencies: [
        // Using SpeziLLM which includes llama.cpp
        .package(url: "https://github.com/StanfordSpezi/SpeziLLM", from: "0.8.0"),
        // Alternative: Direct llama.cpp
        // .package(url: "https://github.com/ggml-org/llama.cpp", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "Wisbee",
            dependencies: [
                .product(name: "SpeziLLM", package: "SpeziLLM"),
                .product(name: "SpeziLLMLocal", package: "SpeziLLM"),
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)