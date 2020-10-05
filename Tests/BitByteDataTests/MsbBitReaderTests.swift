// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitReaderTests: XCTestCase {

    private static let data = Data([0x5A, 0xD6, 0x57, 0x14, 0xAB, 0xCC, 0x2D, 0x88, 0xEA, 0x00])

    func testAdvance() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bit(), 0)
        reader.advance()
        XCTAssertEqual(reader.bit(), 0)
        reader.advance()
        reader.advance()
        XCTAssertEqual(reader.bit(), 0)
        reader.advance(by: 4)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertFalse(reader.isAligned)
    }

    func testBit() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bit(), 0)
        XCTAssertFalse(reader.isAligned)
    }

    func testBits() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bits(count: 0), [])
        var bits = reader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])
        bits = reader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 1, 1, 0])
        XCTAssertFalse(reader.isAligned)
    }

    func testIntFromBits() {
        let reader: MsbBitReader
        if MemoryLayout<Int>.size == 8 {
            reader = MsbBitReader(data: Data([127, 160, 15, 128,
                                              0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                                              0x80, 0, 0, 0, 0, 0, 0, 0]))
        } else if MemoryLayout<Int>.size == 4 {
            reader = MsbBitReader(data: Data([127, 160, 15, 128, 133, 200, 15,
                                              0x7F, 0xFF, 0xFF, 0xFF, 0x80, 0, 0, 0]))
        } else {
            XCTFail("Unsupported Int bit width.")
            return
        }
        XCTAssertEqual(reader.int(fromBits: 8), 127)
        XCTAssertEqual(reader.int(fromBits: 3), 5)
        XCTAssertEqual(reader.int(fromBits: 4), 0)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.int(fromBits: 5), 0)
        XCTAssertEqual(reader.int(fromBits: 12), 3968)
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.int(fromBits: Int.bitWidth), Int.max)
        XCTAssertEqual(reader.int(fromBits: Int.bitWidth), Int.min)
    }

    func testByteFromBits() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.byte(fromBits: 0), 0)
        var num = reader.byte(fromBits: 3)
        XCTAssertEqual(num, 2)
        num = reader.byte(fromBits: 8)
        XCTAssertEqual(num, 214)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.byte(fromBits: 8), 0x57)
    }

    func testUint16FromBits() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.uint16(fromBits: 0), 0)
        var num = reader.uint16(fromBits: 3)
        XCTAssertEqual(num, 2)
        num = reader.uint16(fromBits: 8)
        XCTAssertEqual(num, 214)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.uint16(fromBits: 16), 0x57_14)
    }

    func testUint32FromBits() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBits: 0), 0)
        var num = reader.uint32(fromBits: 3)
        XCTAssertEqual(num, 2)
        num = reader.uint32(fromBits: 8)
        XCTAssertEqual(num, 214)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.uint32(fromBits: 32), 0x57_14_AB_CC)
    }

    func testUint64FromBits() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.uint64(fromBits: 0), 0)
        var num = reader.uint64(fromBits: 3)
        XCTAssertEqual(num, 2)
        num = reader.uint64(fromBits: 8)
        XCTAssertEqual(num, 214)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.uint64(fromBits: 64), 0x57_14_AB_CC_2D_88_EA_00)
    }

    func testIsAligned() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        _ = reader.bits(count: 12)
        XCTAssertFalse(reader.isAligned)
        _ = reader.bits(count: 4)
        XCTAssertTrue(reader.isAligned)
    }

    func testAlign() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        _ = reader.bits(count: 6)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        _ = reader.byte()
        reader.align()
        XCTAssertTrue(reader.isAligned)
    }

    func testBytesLeft() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bytesLeft, 10)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bytesLeft, 9)
        _ = reader.byte()
        XCTAssertEqual(reader.bytesLeft, 8)
        reader.offset = reader.data.endIndex - 1
        XCTAssertEqual(reader.bytesLeft, 1)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bytesLeft, 1)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bytesLeft, 0)
    }

    func testBytesRead() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bytesRead, 0)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bytesRead, 1)
        _ = reader.byte()
        XCTAssertEqual(reader.bytesRead, 2)
        reader.offset = reader.data.endIndex - 1
        XCTAssertEqual(reader.bytesRead, 9)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bytesRead, 9)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bytesRead, 10)
    }

    func testBitReaderByte() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        var byte = reader.byte()
        XCTAssertEqual(byte, 0x5A)
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
        byte = reader.byte()
        XCTAssertEqual(byte, 0xD6)
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
    }

    func testBitReaderBytes() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bytes(count: 0), [])
        let bytes = reader.bytes(count: 2)
        XCTAssertEqual(bytes, [0x5A, 0xD6])
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
    }

    func testBitReaderIntFromBytes() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.int(fromBytes: 0), 0)
        XCTAssertEqual(reader.int(fromBytes: 2), 54874)
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
    }

    func testBitReaderUint16() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.uint16(fromBytes: 0), 0)
        let num = reader.uint16()
        XCTAssertEqual(num, 54874)
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
    }

    func testBitReaderUint32FromBytes() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBytes: 0), 0)
        let num = reader.uint32(fromBytes: 3)
        XCTAssertEqual(num, 5756506)
        XCTAssertTrue(reader.isAligned)
        XCTAssertFalse(reader.isFinished)
    }

    func testBitReaderNonZeroStartIndex() {
        var reader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.byte(), 0xD6)
        reader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.bytes(count: 1), [0xD6])
        reader = MsbBitReader(data: MsbBitReaderTests.data[1...])
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.bit(), 1)
        XCTAssertEqual(reader.bits(count: 3), [1, 0, 1])
        XCTAssertEqual(reader.int(fromBits: 4), 6)
    }

    func testConvertedByteReader() {
        let byteReader = LittleEndianByteReader(data: MsbBitReaderTests.data)
        _ = byteReader.byte()
        var reader = MsbBitReader(byteReader)
        XCTAssertEqual(reader.byte(), 0xD6)
        XCTAssertEqual(reader.bits(count: 4), [0, 1, 0, 1])
        XCTAssertEqual(reader.int(fromBits: 4), 7)
        reader = MsbBitReader(byteReader)
        XCTAssertEqual(reader.bits(count: 4), [1, 1, 0, 1])
        XCTAssertEqual(reader.int(fromBits: 4), 6)
    }

    func testBitsLeft() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bitsLeft, 80)
        _ = reader.bits(count: 4)
        XCTAssertEqual(reader.bitsLeft, 76)
        _ = reader.bits(count: 4)
        XCTAssertEqual(reader.bitsLeft, 72)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bitsLeft, 70)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bitsLeft, 64)
        _ = reader.uint64(fromBits: 64)
        XCTAssertEqual(reader.bitsLeft, 0)
    }

    func testBitsRead() {
        let reader = MsbBitReader(data: MsbBitReaderTests.data)
        XCTAssertEqual(reader.bitsRead, 0)
        _ = reader.bits(count: 4)
        XCTAssertEqual(reader.bitsRead, 4)
        _ = reader.bits(count: 4)
        XCTAssertEqual(reader.bitsRead, 8)
        _ = reader.bits(count: 2)
        XCTAssertEqual(reader.bitsRead, 10)
        _ = reader.bits(count: 6)
        XCTAssertEqual(reader.bitsRead, 16)
    }

}
