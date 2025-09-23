// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ConfigPanel",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ConfigPanel", targets: ["ConfigPanel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jmfieldman/CombineEx.git", from: "0.0.33"),
    ],
    targets: [
        .target(
            name: "ConfigPanel",
            dependencies: [
                .product(name: "CombineEx", package: "CombineEx"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ConfigPanelTests",
            dependencies: ["ConfigPanel"],
            path: "Tests"
        ),
    ]
)
