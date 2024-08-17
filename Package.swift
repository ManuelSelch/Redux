// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Redux",
    platforms: [
        .iOS(.v16), 
        .macOS(.v14),
        .macCatalyst(.v16)
    ],
    products: [
        .library(name: "Redux", targets: ["Redux"]),
        .library(name: "ReduxDebug", targets: ["ReduxDebug"]),
        .library(name: "ReduxTestStore", targets: ["ReduxTestStore"])
    ],
    dependencies: [
        .package(url: "https://github.com/ManuelSelch/Dependencies.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .upToNextMajor(from: "0.6.7")),
        .package(url: "https://github.com/kean/Pulse.git", .upToNextMajor(from: "4.2.7")),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.6"),
        .package(url: "https://github.com/davdroman/swiftui-navigation-transitions.git", .upToNextMajor(from: "0.13.4")),
        .package(url: "https://github.com/exyte/PopupView.git", .upToNextMajor(from: "3.0.5"))
    ],
    targets: [
        .target(
            name: "Redux",
            dependencies: [
                .product(name: "NavigationTransitions", package: "swiftui-navigation-transitions"),
                .product(name: "PopupView", package: "PopupView")
            ]
        ),
        .target(
            name: "ReduxDebug",
            dependencies: [
                "Redux",
                .product(name: "AnyCodable", package: "AnyCodable"),
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "Starscream", package: "Starscream")
            ]
        ),
        .target(
            name: "ReduxTestStore",
            dependencies: [
                "Redux",
                .product(name: "Dependencies", package: "Dependencies")
            ]
        ),
        .testTarget(
            name: "ReduxTests",
            dependencies: ["Redux", "ReduxTestStore"]
        )
    ]
)
