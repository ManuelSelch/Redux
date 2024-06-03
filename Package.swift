// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Redux",
    platforms: [
        .iOS(.v16), .macOS(.v13), .macCatalyst(.v16)
    ],
    products: [
        .library(
            name: "Redux",
            targets: ["Redux"]
        ),
        .library(
            name: "ReduxTests",
            targets: ["ReduxTests"]
        )
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
            dependencies: ["Redux"]
        )
    ]
)
