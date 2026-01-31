// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BitByteData",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "BitByteData",
            targets: ["BitByteData"])
    ],
    targets: [
        .target(name: "BitByteData", path: "Sources", resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "BitByteDataTests", dependencies: ["BitByteData"]),
        .testTarget(name: "BitByteDataBenchmarks", dependencies: ["BitByteData"])
    ],
    swiftLanguageVersions: [.v5]
)
