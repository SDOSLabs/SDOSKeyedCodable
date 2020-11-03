// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SDOSKeyedCodable",
    products: [
        .library(
            name: "SDOSKeyedCodable",
            targets: ["SDOSKeyedCodable"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SDOSKeyedCodable",
            dependencies: [],
            path: "src")
    ]
)
