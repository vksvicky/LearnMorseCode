// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LearnMorseKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MorseCore", targets: ["MorseCore"]),
        .library(name: "LearnMorseUI", targets: ["LearnMorseUI"]),
        .library(name: "MorseReference", targets: ["MorseReference"]),
        .library(name: "TextToMorse", targets: ["TextToMorse"]),
        .library(name: "VoiceToMorse", targets: ["VoiceToMorse"]),
        .library(name: "GameMode", targets: ["GameMode"]),
        .library(name: "Settings", targets: ["Settings"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "MorseCore", dependencies: [], path: "MorseCore"),
        .target(name: "LearnMorseUI", dependencies: ["MorseCore"], path: "LearnMorseUI"),
        .target(name: "MorseReference", dependencies: ["MorseCore", "LearnMorseUI"], path: "Features/MorseReference"),
        .target(name: "TextToMorse", dependencies: ["MorseCore", "LearnMorseUI"], path: "Features/TextToMorse"),
        .target(name: "VoiceToMorse", dependencies: ["MorseCore"], path: "Features/VoiceToMorse"),
        .target(name: "GameMode", dependencies: ["MorseCore", "LearnMorseUI"], path: "Features/GameMode"),
        .target(name: "Settings", dependencies: ["MorseCore"], path: "Features/Settings"),
        .testTarget(name: "MorseCoreTests", dependencies: ["MorseCore"], path: "Tests/MorseCoreTests")
    ]
)
