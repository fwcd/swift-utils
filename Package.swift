// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-utils",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Utils",
            targets: ["Utils"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.0.0"),
        .package(name: "Socket", url: "https://github.com/Kitura/BlueSocket.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.12.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Socket", package: "Socket")
            ]
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]
        )
    ]
)
