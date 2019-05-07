// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Broadcaster",
    products: [
        .library(name: "Broadcaster", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        // Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.3"),
        // Job scheduler
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1"),
        // Leaf templating
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Authentication", "Leaf", "Jobs"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
