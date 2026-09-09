// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "NShiftUI",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "NShiftUI",
            targets: ["NShiftUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest"),
        .package(
            url: "https://gitlab.com/tcc-nshiftui/mobile/ios/packages/rainbowparser.git",
            branch: "release/0.1.0-beta.1"
        ),
    ],
    targets: [
        .target(
            name: "NShiftUIDomain"
        ),
        .target(
            name: "NShiftUIDI",
            dependencies: [
                "NShiftUIDomain",
            ]
        ),
        .macro(
            name: "NShiftUIMacrosImplementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "NShiftUIMacros",
            dependencies: [
                "NShiftUIDomain",
                "NShiftUIDI",
                "NShiftUIMacrosImplementation",
            ]
        ),
        .target(
            name: "NShiftUI",
            dependencies: [
                "NShiftUIDomain",
                "NShiftUIDI",
                "NShiftUIMacros",
                .product(
                    name: "RainbowParser",
                    package: "rainbowparser"
                ),
            ]
        ),
        .testTarget(
            name: "NShiftUITests",
            dependencies: [
                "NShiftUI",
                "NShiftUIDomain",
                "NShiftUIDI",
                "NShiftUIMacros",
                "NShiftUIMacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(
                    name: "RainbowParser",
                    package: "rainbowparser"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
