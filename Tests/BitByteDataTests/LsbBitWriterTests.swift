// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitWriterTests: XCTestCase {

    func testWriteBit() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 1)
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [26])
    }

    func testWriteBitsArray() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [83, 6])
    }

    func testWriteNumber() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(number: 255, bitsCount: 8)
        XCTAssertEqual(bitWriter.buffer, [255])
        bitWriter.write(number: 6, bitsCount: 3)
        XCTAssertEqual(bitWriter.buffer, [255])
        bitWriter.write(number: 103, bitsCount: 7)
        XCTAssertEqual(bitWriter.buffer, [255, 62])
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [255, 62, 3])
    }

    func testFinish() {
        let bitWriter = LsbBitWriter()
        bitWriter.finish()
        XCTAssertEqual(bitWriter.buffer, [0])
    }

}
