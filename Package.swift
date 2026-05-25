// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "BitByteData",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
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
    swiftLanguageModes: [.v5]
)
