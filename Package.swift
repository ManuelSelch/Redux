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
        .library(name: "ReduxTestStore", targets: ["ReduxTestStore"])
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/ManuelSelch/Dependencies.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Redux",
            dependencies: [
                .product(name: "Moya", package: "Moya")
            ]
        ),
        .target(
            name: "ReduxTestStore",
            dependencies: [
                "Redux",
                .product(name: "Dependencies", package: "Dependencies")
            ]
        )
    ]
)
