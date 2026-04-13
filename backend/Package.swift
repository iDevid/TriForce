// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "TriForceBackend",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        .package(path: "../shared/SharedModels")
    ],
    targets: [
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App")
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SharedModels", package: "SharedModels")
            ]
        )
    ]
)
