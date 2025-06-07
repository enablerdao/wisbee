// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OllamaChat",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "OllamaChat",
            targets: ["OllamaChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ggerganov/llama.cpp", branch: "master")
    ],
    targets: [
        .target(
            name: "OllamaChat",
            dependencies: []),
        .testTarget(
            name: "OllamaChatTests",
            dependencies: ["OllamaChat"]),
    ]
)