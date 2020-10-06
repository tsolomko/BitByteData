// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitWriterBenchmarks: XCTestCase {

    func testWriteBit() {
        self.measure {
            let writer = MsbBitWriter()

            for _ in 0..<4_000_000 {
                writer.write(bit: 0)
                writer.write(bit: 1)
            }
        }
    }

    func testWriteNumberBitsCount() {
        self.measure {
            let writer = MsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(number: 55, bitsCount: 7)
            }
        }
    }

    func testWriteUnsignedNumberBitsCount() {
        self.measure {
            let writer = MsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.write(unsignedNumber: 55, bitsCount: 7)
            }
        }
    }

    func testAppendByte() {
        self.measure {
            let writer = MsbBitWriter()

            for _ in 0..<1_000_000 {
                writer.append(byte: 37)
            }
        }
    }

}
