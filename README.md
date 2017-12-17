# BitByteData

[![Swift 4](https://img.shields.io/badge/Swift-4.0-blue.svg)](https://developer.apple.com/swift/)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/tsolomko/BitByteData/master/LICENSE)
[![Build Status](https://travis-ci.org/tsolomko/BitByteData.svg?branch=develop)](https://travis-ci.org/tsolomko/BitByteData)

A Swift framework with classes for reading bytes and bits consequently.

## Installation

Right now only Swift Package manager is supported.
To install using SPM, add BitByteData to you package dependencies
and specify it as a dependency for your target, e.g.:

```swift
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/tsolomko/BitByteData.git",
                 from: "1.0.0")
    ],
    targets: [
        .target(
            name: "TargetName",
            dependencies: ["BitByteData"]
        )
    ]
)
```

More details you can find in [Swift Package Manager's Documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

## Usage

TBD.

### Documentation

Every function or type of BitByteData's public API is documented.
This documentation can be found at its own [website](http://tsolomko.github.io/BitByteData).

## Contributing

Whether you find a bug, have a suggestion, idea or something else,
please [create an issue](https://github.com/tsolomko/BitByteData/issues) on GitHub.

In case you have encoutered a bug, it would be especially helpful if you attach a file (archive, etc.)
that caused the bug to happen.

If you'd like to contribute code, please [create a pull request](https://github.com/tsolomko/BitByteData/pulls) on GitHub.
