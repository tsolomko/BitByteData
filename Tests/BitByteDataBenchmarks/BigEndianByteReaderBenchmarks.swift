// Copyright (c) 2019 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class BigEndianByteReaderBenchmarks: XCTestCase {

    func testByte() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<5_000_000 {
                _ = byteReader.byte()
            }
        }
    }

    func testBytes() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<500_000 {
                _ = byteReader.bytes(count: 20)
            }
        }
    }

    func testIntFromBytes() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 {
                _ = byteReader.int(fromBytes: 7)
            }
        }
    }

    func testUint16() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 {
                _ = byteReader.uint16()
            }
        }
    }

    func testUint16FromBytes() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<2_000_000 {
                _ = byteReader.uint16(fromBytes: 1)
            }
        }
    }

    func testUint32() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<500_000 {
                _ = byteReader.uint32()
            }
        }
    }

    func testUint32FromBytes() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<500_000 {
                _ = byteReader.uint32(fromBytes: 3)
            }
        }
    }

    func testUint64() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_00_000 {
                _ = byteReader.uint64()
            }
        }
    }

    func testUint64FromBytes() {
        self.measure {
            let byteReader = BigEndianByteReader(data: Data(count: 10_485_760)) // 10 MB

            for _ in 0..<1_000_000 {
                _ = byteReader.uint64(fromBytes: 7)
            }
        }
    }

}
