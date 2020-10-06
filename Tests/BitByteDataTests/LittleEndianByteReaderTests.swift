// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LittleEndianByteReaderTests: XCTestCase {

    private static let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])

    func testByte() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)

        let byte = reader.byte()
        XCTAssertEqual(byte, 0)
        XCTAssertFalse(reader.isFinished)
    }

    func testIsFinished() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        reader.offset = 9
        XCTAssertTrue(reader.isFinished)
    }

    func testBytesLeft() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytesLeft, 9)
        _ = reader.uint16()
        XCTAssertEqual(reader.bytesLeft, 7)
        reader.offset = reader.data.endIndex
        XCTAssertEqual(reader.bytesLeft, 0)
    }

    func testBytesRead() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytesRead, 0)
        _ = reader.uint16()
        XCTAssertEqual(reader.bytesRead, 2)
        reader.offset = reader.data.endIndex
        XCTAssertEqual(reader.bytesRead, 9)
    }

    func testBytes() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytes(count: 0), [])
        let bytes = reader.bytes(count: 4)
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03])
    }

    func testIntFromBytes() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.int(fromBytes: 0), 0)
        XCTAssertEqual(reader.int(fromBytes: 3), 131328)
        XCTAssertEqual(reader.int(fromBytes: 2), 1027)
        XCTAssertEqual(reader.int(fromBytes: 4), 134678021)
        XCTAssertTrue(reader.isFinished)
    }

    func testUint64() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        let num = reader.uint64()
        XCTAssertEqual(num, 0x0706050403020100)
    }

    func testUint64FromBytes() {
        var reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint64(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint64(fromBytes: 3), 131328)
        XCTAssertFalse(reader.isFinished)

        reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint64(fromBytes: 8), 0x0706050403020100)
        XCTAssertFalse(reader.isFinished)
    }

    func testUint32() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        let num = reader.uint32()
        XCTAssertEqual(num, 0x03020100)
    }

    func testUint32FromBytes() {
        var reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint32(fromBytes: 3), 131328)
        XCTAssertFalse(reader.isFinished)

        reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBytes: 4), 0x03020100)
        XCTAssertFalse(reader.isFinished)
    }

    func testUint16() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        let num = reader.uint16()
        XCTAssertEqual(num, 0x0100)
    }

    func testUint16FromBytes() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint16(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint16(fromBytes: 2), 256)
        XCTAssertFalse(reader.isFinished)
    }

    func testNonZeroStartIndex() {
        let reader = LittleEndianByteReader(data: LittleEndianByteReaderTests.data[1...])
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.uint16(), 0x0201)
        XCTAssertEqual(reader.offset, 3)
        XCTAssertEqual(reader.uint32(), 0x06050403)
        XCTAssertEqual(reader.offset, 7)
        XCTAssertEqual(reader.byte(), 0x07)
        XCTAssertEqual(reader.bytes(count: 1), [0x08])
    }

}
