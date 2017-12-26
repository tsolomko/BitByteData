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
        XCTAssertEqual(bitWriter.data, Data(bytes: [88]))
    }

    func testWriteBitsArray() {
        let bitWriter = MsbBitWriter()

        bitWriter.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        bitWriter.finish()
        XCTAssertEqual(bitWriter.data, Data(bytes: [202, 96]))
    }

    func testWriteNumber() {
        let bitWriter = MsbBitWriter()

        bitWriter.write(number: 255, bitsCount: 8)
        XCTAssertEqual(bitWriter.data, Data(bytes: [255]))

        bitWriter.write(number: 6, bitsCount: 3)
        XCTAssertEqual(bitWriter.data, Data(bytes: [255]))

        bitWriter.write(number: 103, bitsCount: 7)
        XCTAssertEqual(bitWriter.data, Data(bytes: [255, 217]))

        bitWriter.finish()
        XCTAssertEqual(bitWriter.data, Data(bytes: [255, 217, 192]))
    }

    func testAppendByte() {
        let bitWriter = LsbBitWriter()

        bitWriter.append(byte: 0xCA)
        XCTAssertEqual(bitWriter.data, Data(bytes: [0xCA]))
    }

    func testFinish() {
        let bitWriter = MsbBitWriter()

        bitWriter.finish()
        XCTAssertEqual(bitWriter.data, Data(bytes: [0]))
        XCTAssertTrue(bitWriter.isAligned)
    }

    func testIsAligned() {
        let bitWriter = MsbBitWriter()

        bitWriter.write(bits: [0, 1, 0])
        XCTAssertFalse(bitWriter.isAligned)
        bitWriter.write(bits: [0, 1, 0, 1, 0])
        XCTAssertTrue(bitWriter.isAligned)

        bitWriter.write(bit: 0)
        XCTAssertFalse(bitWriter.isAligned)
        bitWriter.finish()
        XCTAssertTrue(bitWriter.isAligned)
    }

}
