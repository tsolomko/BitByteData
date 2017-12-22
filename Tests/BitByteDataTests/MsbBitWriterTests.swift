// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitWriterTests: XCTestCase {

    func testWriteBit() {
        let bitWriter = MsbBitWriter()
        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 1)
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [88])
    }

    func testWriteBitsArray() {
        let bitWriter = MsbBitWriter()
        bitWriter.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [202, 96])
    }

    func testWriteNumber() {
        let bitWriter = MsbBitWriter()
        bitWriter.write(number: 255, bitsCount: 8)
        XCTAssertEqual(bitWriter.buffer, [255])
        bitWriter.write(number: 6, bitsCount: 3)
        XCTAssertEqual(bitWriter.buffer, [255])
        bitWriter.write(number: 103, bitsCount: 7)
        XCTAssertEqual(bitWriter.buffer, [255, 217])
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [255, 217, 192])
    }

    func testFinish() {
        let bitWriter = MsbBitWriter()
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [0])
    }

}
