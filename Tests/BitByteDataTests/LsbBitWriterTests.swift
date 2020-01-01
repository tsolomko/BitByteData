// Copyright (c) 2020 Timofey Solomko
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
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([26]))
    }

    func testWriteBitsArray() {
        let bitWriter = LsbBitWriter()

        bitWriter.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([83, 6]))
    }

    func testWriteNumber() {
        let bitWriter = LsbBitWriter()

        bitWriter.write(number: 255, bitsCount: 8)
        XCTAssertEqual(bitWriter.data, Data([255]))
        bitWriter.write(number: 6, bitsCount: 3)
        XCTAssertEqual(bitWriter.data, Data([255]))
        bitWriter.write(number: 103, bitsCount: 7)
        XCTAssertEqual(bitWriter.data, Data([255, 62]))
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([255, 62, 3]))
    }

    func testWriteUnsignedNumber() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(unsignedNumber: UInt(UInt64.max), bitsCount: UInt64.bitWidth)

        let byteReader = LittleEndianByteReader(data: bitWriter.data)
        XCTAssertEqual(byteReader.uint64(), UInt64.max)
    }

    func testAppendByte() {
        let bitWriter = LsbBitWriter()

        bitWriter.append(byte: 0xCA)
        XCTAssertEqual(bitWriter.data, Data([0xCA]))
    }

    func testAlign() {
        let bitWriter = LsbBitWriter()

        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data())
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
        bitWriter.align()
        XCTAssertTrue(bitWriter.isAligned)
    }

    func testNamingConsistency() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(number: 14582, bitsCount: 14)
        bitWriter.align()

        let bitReader = LsbBitReader(data: bitWriter.data)
        XCTAssertEqual(bitReader.int(fromBits: 14), 14582)
    }

}
