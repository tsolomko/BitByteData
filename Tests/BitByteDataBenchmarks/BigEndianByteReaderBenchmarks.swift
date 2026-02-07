// Copyright (c) 2026 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class BigEndianByteReaderBenchmarks: XCTestCase {

    func testByte() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<50_000_000 {
                _ = reader.byte()
            }
        }
    }

    func testBytes() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 262_144_000)) // 250 MB

            for _ in 0..<12_500_000 {
                _ = reader.bytes(count: 20)
            }
        }
    }

    func testIntFromBytes() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<10_000_000 {
                _ = reader.int(fromBytes: 7)
            }
        }
    }

    func testUint16() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<50_000_000 {
                _ = reader.uint16()
            }
        }
    }

    func testUint16_FB() { // For comparison with no-argument version.
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<50_000_000 {
                _ = reader.uint16(fromBytes: 2)
            }
        }
    }

    func testUint16FromBytes() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<50_000_000 {
                _ = reader.uint16(fromBytes: 1)
            }
        }
    }

    func testUint32() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint32()
            }
        }
    }

    func testUint32_FB() { // For comparison with no-argument version.
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint32(fromBytes: 4)
            }
        }
    }

    func testUint32FromBytes() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 104_857_600)) // 100 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint32(fromBytes: 3)
            }
        }
    }

    func testUint64() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 209_715_200)) // 200 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint64()
            }
        }
    }

    func testUint64_FB() { // For comparison with no-argument version.
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 209_715_200)) // 200 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint64(fromBytes: 8)
            }
        }
    }

    func testUint64FromBytes() {
        self.measure {
            let reader = BigEndianByteReader(data: Data(count: 209_715_200)) // 200 MB

            for _ in 0..<20_000_000 {
                _ = reader.uint64(fromBytes: 7)
            }
        }
    }

}
