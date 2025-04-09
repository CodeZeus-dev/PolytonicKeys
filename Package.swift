// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GreekPolytonicKeyboard",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GreekPolytonicKeyboard",
            targets: ["GreekPolytonicKeyboard"]),
        .executable(
            name: "GreekPolytonicKeyboardApp",
            targets: ["GreekPolytonicKeyboardApp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GreekPolytonicKeyboard",
            dependencies: [],
            path: "GreekPolytonicKeyboard"),
        .target(
            name: "GreekPolytonicKeyboardApp",
            dependencies: ["GreekPolytonicKeyboard"],
            path: "GreekPolytonicKeyboardApp")
    ]
)