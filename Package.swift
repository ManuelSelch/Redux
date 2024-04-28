// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Redux",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(
            name: "Redux",
            targets: ["Redux"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0"))
    ],
    targets: [
        .target(
            name: "Redux",
            dependencies: [
                .product(name: "Moya", package: "Moya")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ReduxTests",
            dependencies: ["Redux"]),
    ]
)
