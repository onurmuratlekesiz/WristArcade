// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WristArcade",
    defaultLocalization: "en",
    platforms: [
        .watchOS(.v9),
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WristArcade",
            targets: ["WristArcade"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WristArcade",
            dependencies: [],
            path: ".",
            exclude: [
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "WristArcadeTests",
            dependencies: ["WristArcade"],
            path: "Tests"
        ),
    ]
)
