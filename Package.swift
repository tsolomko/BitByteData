// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "BitByteData",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
        // TODO: Enable after upgrading to Swift 5.9.
        // .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BitByteData",
            targets: ["BitByteData"])
    ],
    targets: [
        .target(name: "BitByteData", path: "Sources"),
        .testTarget(name: "BitByteDataTests", dependencies: ["BitByteData"]),
        .testTarget(name: "BitByteDataBenchmarks", dependencies: ["BitByteData"])
    ],
    swiftLanguageVersions: [.v5]
)
