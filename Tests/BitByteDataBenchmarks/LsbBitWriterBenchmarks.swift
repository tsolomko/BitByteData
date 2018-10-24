// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitWriterBenchmarks: XCTestCase {

    func testWriteBit() {
        self.measure {
            let bitWriter = LsbBitWriter()

            for _ in 0..<4_000_000 {
                bitWriter.write(bit: 0)
                bitWriter.write(bit: 1)
            }
        }
    }

    func testWriteNumberBitsCount() {
        self.measure {
            let bitWriter = LsbBitWriter()

            for _ in 0..<1_000_000 {
                bitWriter.write(number: 55, bitsCount: 7)
            }
        }
    }

    func testAppendByte() {
        self.measure {
            let bitWriter = LsbBitWriter()

            for _ in 0..<1_000_000 {
                bitWriter.append(byte: 37)
            }
        }
    }

}
