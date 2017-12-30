// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitReaderTests: XCTestCase {

    private static let data = Data(bytes: [0x5A, 0xD6])

    func testBit() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var bits = bitReader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])

        bits = bitReader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 0, 1, 1])

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIntFromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var num = bitReader.intFromBits(count: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.intFromBits(count: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIsAligned() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 12)
        XCTAssertFalse(bitReader.isAligned)

        _ = bitReader.bits(count: 4)
        XCTAssertTrue(bitReader.isAligned)
    }

    func testAlign() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        _ = bitReader.byte()

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)
    }

    func testBitReaderByte() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var byte = bitReader.byte()
        XCTAssertEqual(byte, 0x5A)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)

        byte = bitReader.byte()
        XCTAssertEqual(byte, 0xD6)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertTrue(bitReader.isFinished)
    }

    func testBitReaderBytes() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        let bytes = bitReader.bytes(count: 2)
        XCTAssertEqual(bytes, [0x5A, 0xD6])
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertTrue(bitReader.isFinished)
    }

    func testBitReaderUint16() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        let num = bitReader.uint16()
        XCTAssertEqual(num, 54874)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertTrue(bitReader.isFinished)
    }

}
