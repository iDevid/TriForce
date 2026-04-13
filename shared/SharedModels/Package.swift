// swift-tools-version: 6.3
import PackageDescription
import Foundation

let isAndroidBuild = ProcessInfo.processInfo.environment["ANDROID_BUILD"] == "1"
let localSwiftJavaPath = "../../swift-java"

let swiftJavaPackage: [Package.Dependency] = isAndroidBuild
    ? [.package(path: localSwiftJavaPath)]
    : []

let swiftJavaDependency: [Target.Dependency] = isAndroidBuild
    ? [.product(name: "SwiftJava", package: "swift-java")]
    : []

let swiftJavaPlugin: [Target.PluginUsage] = isAndroidBuild
    ? [.plugin(name: "JExtractSwiftPlugin", package: "swift-java")]
    : []

let sharedModelsProducts: [Product] = isAndroidBuild
    ? [
        .library(
            name: "SharedModels",
            type: .dynamic,
            targets: ["SharedModels"]
        )
    ]
    : [
        .library(
            name: "SharedModels",
            targets: ["SharedModels"]
        )
    ]

let package = Package(
    name: "SharedModels",
    platforms: [.macOS(.v13)],
    products: sharedModelsProducts,
    dependencies: swiftJavaPackage,
    targets: [
        .target(
            name: "SharedModels",
            dependencies: swiftJavaDependency,
            exclude: ["swift-java.config"],
            plugins: swiftJavaPlugin
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: ["SharedModels"]
        )
    ]
)
