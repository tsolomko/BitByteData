// Copyright (c) 2019 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class BigEndianByteReaderTests: XCTestCase {

    private static let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])

    func testByte() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)

        let byte = byteReader.byte()
        XCTAssertEqual(byte, 0)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testIsFinished() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        byteReader.offset = 9
        XCTAssertTrue(byteReader.isFinished)
    }

    func testBytesLeft() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.bytesLeft, 9)
        _ = byteReader.uint16()
        XCTAssertEqual(byteReader.bytesLeft, 7)
        byteReader.offset = byteReader.data.endIndex
        XCTAssertEqual(byteReader.bytesLeft, 0)
    }

    func testBytesRead() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.bytesRead, 0)
        _ = byteReader.uint16()
        XCTAssertEqual(byteReader.bytesRead, 2)
        byteReader.offset = byteReader.data.endIndex
        XCTAssertEqual(byteReader.bytesRead, 9)
    }

    func testBytes() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.bytes(count: 0), [])
        let bytes = byteReader.bytes(count: 4)
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03])
    }

    func testIntFromBytes() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.int(fromBytes: 0), 0)
        XCTAssertEqual(byteReader.int(fromBytes: 3), 258)
        XCTAssertEqual(byteReader.int(fromBytes: 2), 772)
        XCTAssertEqual(byteReader.int(fromBytes: 4), 84281096)
        XCTAssertTrue(byteReader.isFinished)
    }

    func testUint64() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = byteReader.uint64()
        XCTAssertEqual(num, 0x0001020304050607)
    }

    func testUint64FromBytes() {
        var byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.uint64(fromBytes: 0), 0)
        XCTAssertEqual(byteReader.uint64(fromBytes: 3), 258)
        XCTAssertFalse(byteReader.isFinished)

        byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.uint64(fromBytes: 8), 0x0001020304050607)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testUint32() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = byteReader.uint32()
        XCTAssertEqual(num, 0x00010203)
    }

    func testUint32FromBytes() {
        var byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.uint32(fromBytes: 0), 0)
        XCTAssertEqual(byteReader.uint32(fromBytes: 3), 258)
        XCTAssertFalse(byteReader.isFinished)

        byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.uint32(fromBytes: 4), 0x00010203)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testUint16() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = byteReader.uint16()
        XCTAssertEqual(num, 0x0001)
    }

    func testUint16FromBytes() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(byteReader.uint16(fromBytes: 0), 0)
        XCTAssertEqual(byteReader.uint16(fromBytes: 2), 1)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testNonZeroStartIndex() {
        let byteReader = BigEndianByteReader(data: BigEndianByteReaderTests.data[1...])
        XCTAssertEqual(byteReader.offset, 1)
        XCTAssertEqual(byteReader.uint16(), 0x0102)
        XCTAssertEqual(byteReader.offset, 3)
        XCTAssertEqual(byteReader.uint32(), 0x03040506)
        XCTAssertEqual(byteReader.offset, 7)
        XCTAssertEqual(byteReader.byte(), 0x07)
        XCTAssertEqual(byteReader.bytes(count: 1), [0x08])
    }

}
