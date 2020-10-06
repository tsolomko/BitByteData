// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitReaderBenchmarks: XCTestCase {

    func testAdvance() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<5_000_000 * 8 {
                reader.advance()
            }
        }
    }

    func testAdvanceRealistic() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<9_300_000 {
                reader.advance(by: 6)
                reader.advance(by: 3)
            }
        }
    }

    func testBit() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<5_000_000 * 8 {
                _ = reader.bit()
            }
        }
    }

    func testBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 8 {
                _ = reader.bits(count: 5)
            }
        }
    }

    func testIntFromBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 4 {
                _ = reader.int(fromBits: 10)
            }
        }
    }

    func testByteFromBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 8 {
                _ = reader.byte(fromBits: 6)
            }
        }
    }

    func testUint16FromBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 4 {
                _ = reader.uint16(fromBits: 13)
            }
        }
    }

    func testUint32FromBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 * 3 {
                _ = reader.uint32(fromBits: 23)
            }
        }
    }

    func testUint64FromBits() {
        self.measure {
            let reader = MsbBitReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 {
                _ = reader.uint64(fromBits: 52)
            }
        }
    }

}
