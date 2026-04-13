// swift-tools-version: 6.3
import CompilerPluginSupport
import PackageDescription
import Foundation

let isAndroidBuild = ProcessInfo.processInfo.environment["ANDROID_BUILD"] == "1"
let localSwiftJavaPath = "../../swift-java"

struct AndroidDependencies {
    let packages: [Package.Dependency]
    let targetDependencies: [Target.Dependency]
    let plugins: [Target.PluginUsage]
}

let androidDependencies = isAndroidBuild
    ? AndroidDependencies(
        packages: [
            .package(path: localSwiftJavaPath)
        ],
        targetDependencies: [
            .product(name: "SwiftJava", package: "swift-java")
        ],
        plugins: [
            .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
        ]
        )
    : AndroidDependencies(packages: [], targetDependencies: [], plugins: [])

let sharedNetworkLayerProducts: [Product] = isAndroidBuild
    ? [
        .library(
            name: "SharedNetworkLayer",
            type: .dynamic,
            targets: ["SharedNetworkLayer"]
        )
    ]
    : [
        .library(
            name: "SharedNetworkLayer",
            targets: ["SharedNetworkLayer"]
        )
    ]

let package = Package(
    name: "SharedNetworkLayer",
    platforms: [.iOS(.v26), .macOS(.v13)],
    products: sharedNetworkLayerProducts,
    dependencies: [
        .package(path: "../SharedModels")
    ] + androidDependencies.packages,
    targets: [
        .target(
            name: "SharedNetworkLayer",
            dependencies: [
                .product(name: "SharedModels", package: "SharedModels")
            ] + androidDependencies.targetDependencies,
            exclude: ["swift-java.config"],
            swiftSettings: [
                .unsafeFlags(
                    ["-strict-concurrency=minimal"],
                    .when(platforms: [.android])
                )
            ],
            plugins: androidDependencies.plugins
        )
    ]
)
