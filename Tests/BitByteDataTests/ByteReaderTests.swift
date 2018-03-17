// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class ByteReaderTests: XCTestCase {

    private static let data = Data(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])

    func testByte() {
        let byteReader = ByteReader(data: ByteReaderTests.data)

        let byte = byteReader.byte()
        XCTAssertEqual(byte, 0)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testIsFinished() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        byteReader.offset = 9
        XCTAssertTrue(byteReader.isFinished)
    }

    func testBytesLeft() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.bytesLeft, 9)
        _ = byteReader.uint16()
        XCTAssertEqual(byteReader.bytesLeft, 7)
        byteReader.offset = byteReader.data.endIndex
        XCTAssertEqual(byteReader.bytesLeft, 0)
    }

    func testBytesRead() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.bytesRead, 0)
        _ = byteReader.uint16()
        XCTAssertEqual(byteReader.bytesRead, 2)
        byteReader.offset = byteReader.data.endIndex
        XCTAssertEqual(byteReader.bytesRead, 9)
    }

    func testBytes() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let bytes = byteReader.bytes(count: 4)
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03])
    }

    func testIntFromBytes() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.int(fromBytes: 3), 131328)
        XCTAssertEqual(byteReader.int(fromBytes: 2), 1027)
        XCTAssertEqual(byteReader.int(fromBytes: 4), 134678021)
        XCTAssertTrue(byteReader.isFinished)
    }

    func testUint64() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint64()
        XCTAssertEqual(num, 0x0706050403020100)
    }

    func testUint64FromBytes() {
        var byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.uint64(fromBytes: 3), 131328)
        XCTAssertFalse(byteReader.isFinished)

        byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.uint64(fromBytes: 8), 0x0706050403020100)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testUint32() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint32()
        XCTAssertEqual(num, 0x03020100)
    }

    func testUint32FromBytes() {
        var byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.uint32(fromBytes: 3), 131328)
        XCTAssertFalse(byteReader.isFinished)

        byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.uint32(fromBytes: 4), 0x03020100)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testUint16() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint16()
        XCTAssertEqual(num, 0x0100)
    }

    func testUint16FromBytes() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        XCTAssertEqual(byteReader.uint16(fromBytes: 2), 256)
        XCTAssertFalse(byteReader.isFinished)
    }

    func testNonZeroStartIndex() {
        let byteReader = ByteReader(data: ByteReaderTests.data[1...])
        XCTAssertEqual(byteReader.uint16(), 0x0201)
        XCTAssertEqual(byteReader.uint32(), 0x06050403)
        XCTAssertEqual(byteReader.byte(), 0x07)
        XCTAssertEqual(byteReader.bytes(count: 1), [0x08])
    }

}
