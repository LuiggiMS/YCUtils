// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YCUtils",
    platforms: [
        .macOS(.v13),  // Specifies macOS 13 as the minimum supported version
        .iOS(.v15)     // Specifies iOS 15 as the minimum supported version
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "YCUtils",
            targets: ["YCUtils"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "YCUtils"),
        .testTarget(
            name: "YCUtilsTests",
            dependencies: ["YCUtils"],
            resources: [.copy("Resources/swift-logo.png")]
        ),
    ]
)
