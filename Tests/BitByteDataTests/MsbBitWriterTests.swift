// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitWriterTests: XCTestCase {

    func testWriteBit() {
        let writer = MsbBitWriter()
        writer.write(bit: 0)
        writer.write(bit: 1)
        writer.write(bit: 0)
        writer.write(bit: 1)
        writer.write(bit: 1)
        writer.align()
        XCTAssertEqual(writer.data, Data([88]))
    }

    func testWriteBitsArray() {
        let writer = MsbBitWriter()
        writer.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        writer.align()
        XCTAssertEqual(writer.data, Data([202, 96]))
    }

    func testWriteNumber() {
        let writer = MsbBitWriter()
        writer.write(number: 255, bitsCount: 8)
        XCTAssertEqual(writer.data, Data([255]))
        writer.write(number: 6, bitsCount: 3)
        XCTAssertEqual(writer.data, Data([255]))
        writer.write(number: 103, bitsCount: 7)
        XCTAssertEqual(writer.data, Data([255, 217]))
        writer.align()
        XCTAssertEqual(writer.data, Data([255, 217, 192]))
        writer.write(number: -123, bitsCount: 8)
        XCTAssertEqual(writer.data, Data([255, 217, 192, 133]))
        writer.write(number: -56, bitsCount: 12)
        XCTAssertEqual(writer.data, Data([255, 217, 192, 133, 252]))
        writer.align()
        XCTAssertEqual(writer.data, Data([255, 217, 192, 133, 252, 128]))
        writer.write(number: Int.max, bitsCount: Int.bitWidth)
        writer.write(number: Int.min, bitsCount: Int.bitWidth)
        if Int.bitWidth == 64 {
            XCTAssertEqual(writer.data, Data([255, 217, 192, 133, 252, 128,
                                              0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                                              0x80, 0, 0, 0, 0, 0, 0, 0]))
        } else if Int.bitWidth == 32 {
            XCTAssertEqual(writer.data, Data([255, 217, 192, 133, 252, 128, 0x7F, 0xFF, 0xFF, 0xFF, 0x80, 0, 0, 0]))
        }
    }

    func testWriteUnsignedNumber() {
        let writer = MsbBitWriter()
        writer.write(unsignedNumber: UInt.max, bitsCount: UInt.bitWidth)
        if UInt.bitWidth == 64 {
            XCTAssertEqual(writer.data, Data([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]))
        } else if UInt.bitWidth == 32 {
            XCTAssertEqual(writer.data, Data([0xFF, 0xFF, 0xFF, 0xFF]))
        }
    }

    func testAppendByte() {
        let writer = MsbBitWriter()
        writer.append(byte: 0xCA)
        XCTAssertEqual(writer.data, Data([0xCA]))
        writer.append(byte: 0xFF)
        XCTAssertEqual(writer.data, Data([0xCA, 0xFF]))
        writer.append(byte: 0)
        XCTAssertEqual(writer.data, Data([0xCA, 0xFF, 0]))
    }

    func testAlign() {
        let writer = MsbBitWriter()
        writer.align()
        XCTAssertEqual(writer.data, Data())
        XCTAssertTrue(writer.isAligned)
    }

    func testIsAligned() {
        let writer = MsbBitWriter()
        writer.write(bits: [0, 1, 0])
        XCTAssertFalse(writer.isAligned)
        writer.write(bits: [0, 1, 0, 1, 0])
        XCTAssertTrue(writer.isAligned)
        writer.write(bit: 0)
        XCTAssertFalse(writer.isAligned)
        writer.align()
        XCTAssertTrue(writer.isAligned)
    }

    func testNamingConsistency() {
        let writer = MsbBitWriter()
        writer.write(signedNumber: 14582, bitsCount: 15)
        writer.align()
        let reader = MsbBitReader(data: writer.data)
        XCTAssertEqual(reader.signedInt(fromBits: 15), 14582)
    }

}
