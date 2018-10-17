// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitReaderBenchmarks: XCTestCase {

    func testBit() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<5_000_000 * 8 {
                _ = bitReader.bit()
            }
        }
    }

    func testBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 8 {
                _ = bitReader.bits(count: 5)
            }
        }
    }

    func testIntFromBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 4 {
                _ = bitReader.int(fromBits: 10)
            }
        }
    }

    func testByteFromBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 8 {
                _ = bitReader.byte(fromBits: 6)
            }
        }
    }

    func testUint16FromBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 4 {
                _ = bitReader.uint16(fromBits: 13)
            }
        }
    }

    func testUint32FromBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 3 {
                _ = bitReader.uint32(fromBits: 23)
            }
        }
    }

    func testUint64FromBits() {
        self.measure {
            let bitReader = LsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 {
                _ = bitReader.uint64(fromBits: 52)
            }
        }
    }

}
