// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TypedRegistryPrototype",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
    ],
    products: [
        .library(name: "TypedRegistryPrototype", targets: ["TypedRegistryPrototype"]),
    ],
    targets: [
        .target(name: "TypedRegistryPrototype"),
        .testTarget(
            name: "TypedRegistryPrototypeTests",
            dependencies: ["TypedRegistryPrototype"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
