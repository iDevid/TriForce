// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "TriforceAndroidBridge",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../../shared/SharedModels"),
        .package(path: "../../shared/SharedNetworkLayer")
    ],
    targets: [
        .target(
            name: "TriforceAndroidBridge",
            dependencies: [
                .product(name: "SharedModels", package: "SharedModels"),
                .product(name: "SharedNetworkLayer", package: "SharedNetworkLayer")
            ]
        )
    ]
)
