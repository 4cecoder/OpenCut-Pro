// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpenVideoEditor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "open-video-editor", targets: ["OpenVideoEditor"]),
        .library(name: "OpenVideoCore", targets: ["OpenVideoCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "OpenVideoEditor",
            dependencies: [
                "OpenVideoCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "OpenVideoCore",
            dependencies: []
        ),
        .testTarget(
            name: "OpenVideoCoreTests",
            dependencies: ["OpenVideoCore"]
        )
    ]
)
