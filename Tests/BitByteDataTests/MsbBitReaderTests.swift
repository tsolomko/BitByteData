// Copyright (c) 2019 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitReaderTests: XCTestCase {

    private static let data = Data(bytes: [0x5A, 0xD6, 0x57, 0x14, 0xAB, 0xCC, 0x2D, 0x88, 0xEA, 0x00])

    func testAdvance() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance()
        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance()
        bitReader.advance()
        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance(by: 4)
        XCTAssertEqual(bitReader.bit(), 0)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testBit() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bits(count: 0), [])
        var bits = bitReader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])

        bits = bitReader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 1, 1, 0])

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIntFromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.int(fromBits: 0), 0)
        var num = bitReader.int(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.int(fromBits: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testByteFromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.byte(fromBits: 0), 0)
        var num = bitReader.byte(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.byte(fromBits: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.byte(fromBits: 8), 0x57)
    }

    func testUint16FromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint16(fromBits: 0), 0)
        var num = bitReader.uint16(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint16(fromBits: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint16(fromBits: 16), 0x57_14)
    }

    func testUint32FromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint32(fromBits: 0), 0)
        var num = bitReader.uint32(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint32(fromBits: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint32(fromBits: 32), 0x57_14_AB_CC)
    }

    func testUint64FromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint64(fromBits: 0), 0)
        var num = bitReader.uint64(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint64(fromBits: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint64(fromBits: 64), 0x57_14_AB_CC_2D_88_EA_00)
    }

    func testIsAligned() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        _ = bitReader.bits(count: 12)
        XCTAssertFalse(bitReader.isAligned)

        _ = bitReader.bits(count: 4)
        XCTAssertTrue(bitReader.isAligned)
    }

    func testAlign() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        _ = bitReader.byte()

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)
    }

    func testBytesLeft() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesLeft, 10)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesLeft, 9)
        _ = bitReader.byte()
        XCTAssertEqual(bitReader.bytesLeft, 8)
        bitReader.offset = bitReader.data.endIndex - 1
        XCTAssertEqual(bitReader.bytesLeft, 1)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesLeft, 1)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesLeft, 0)
    }

    func testBytesRead() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesRead, 0)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesRead, 1)
        _ = bitReader.byte()
        XCTAssertEqual(bitReader.bytesRead, 2)
        bitReader.offset = bitReader.data.endIndex - 1
        XCTAssertEqual(bitReader.bytesRead, 9)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesRead, 9)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesRead, 10)
    }

    func testBitReaderByte() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        var byte = bitReader.byte()
        XCTAssertEqual(byte, 0x5A)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)

        byte = bitReader.byte()
        XCTAssertEqual(byte, 0xD6)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderBytes() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bytes(count: 0), [])
        let bytes = bitReader.bytes(count: 2)
        XCTAssertEqual(bytes, [0x5A, 0xD6])
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderIntFromBytes() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(bitReader.int(fromBytes: 0), 0)
        XCTAssertEqual(bitReader.int(fromBytes: 2), 54874)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderUint16() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint16(fromBytes: 0), 0)
        let num = bitReader.uint16()
        XCTAssertEqual(num, 54874)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderUint32FromBytes() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint32(fromBytes: 0), 0)
        let num = bitReader.uint32(fromBytes: 3)
        XCTAssertEqual(num, 5756506)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderNonZeroStartIndex() {
        var bitReader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.byte(), 0xD6)
        bitReader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.bytes(count: 1), [0xD6])
        bitReader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bits(count: 3), [1, 0, 1])
        XCTAssertEqual(bitReader.int(fromBits: 4), 6)
    }

    func testConvertedByteReader() {
        let byteReader = ByteReader(data: MsbBitReaderTests.data)
        _ = byteReader.byte()

        var bitReader = MsbBitReader(byteReader)
        XCTAssertEqual(bitReader.byte(), 0xD6)
        XCTAssertEqual(bitReader.bits(count: 4), [0, 1, 0, 1])
        XCTAssertEqual(bitReader.int(fromBits: 4), 7)

        bitReader = MsbBitReader(byteReader)
        XCTAssertEqual(bitReader.bits(count: 4), [1, 1, 0, 1])
        XCTAssertEqual(bitReader.int(fromBits: 4), 6)
    }

    func testBitsLeft() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bitsLeft, 80)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsLeft, 76)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsLeft, 72)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bitsLeft, 70)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bitsLeft, 64)
        _ = bitReader.uint64(fromBits: 64)
        XCTAssertEqual(bitReader.bitsLeft, 0)
    }

    func testBitsRead() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bitsRead, 0)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsRead, 4)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsRead, 8)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bitsRead, 10)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bitsRead, 16)
    }

}
