// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class BigEndianByteReaderTests: XCTestCase {

    private static let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])

    func testByte() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)

        let byte = reader.byte()
        XCTAssertEqual(byte, 0)
        XCTAssertFalse(reader.isFinished)
    }

    func testIsFinished() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        reader.offset = 9
        XCTAssertTrue(reader.isFinished)
    }

    func testBytesLeft() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytesLeft, 9)
        _ = reader.uint16()
        XCTAssertEqual(reader.bytesLeft, 7)
        reader.offset = reader.data.endIndex
        XCTAssertEqual(reader.bytesLeft, 0)
    }

    func testBytesRead() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytesRead, 0)
        _ = reader.uint16()
        XCTAssertEqual(reader.bytesRead, 2)
        reader.offset = reader.data.endIndex
        XCTAssertEqual(reader.bytesRead, 9)
    }

    func testBytes() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.bytes(count: 0), [])
        let bytes = reader.bytes(count: 4)
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03])
    }

    func testIntFromBytes() {
        var reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.int(fromBytes: 0), 0)
        XCTAssertEqual(reader.int(fromBytes: 3), 258)
        XCTAssertEqual(reader.int(fromBytes: 2), 772)
        XCTAssertEqual(reader.int(fromBytes: 4), 84281096)
        XCTAssertTrue(reader.isFinished)
        
        if MemoryLayout<Int>.size == 8 {
            reader = BigEndianByteReader(data: Data([//127, 160, 15, 128,
                                              0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                                              0x80, 0, 0, 0, 0, 0, 0, 0]))
        } else if MemoryLayout<Int>.size == 4 {
            reader = BigEndianByteReader(data: Data([//127, 160, 15, 128, 133, 200, 15,
                                              0x7F, 0xFF, 0xFF, 0xFF, 0x80, 0, 0, 0]))
        } else {
            XCTFail("Unsupported Int bit width.")
            return
        }
        XCTAssertEqual(reader.int(fromBytes: MemoryLayout<Int>.size), Int.max)
        XCTAssertEqual(reader.int(fromBytes: MemoryLayout<Int>.size), Int.min)
    }

    func testUint64() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = reader.uint64()
        XCTAssertEqual(num, 0x0001020304050607)
    }

    func testUint64FromBytes() {
        var reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint64(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint64(fromBytes: 3), 258)
        XCTAssertFalse(reader.isFinished)

        reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint64(fromBytes: 8), 0x0001020304050607)
        XCTAssertFalse(reader.isFinished)
    }

    func testUint32() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = reader.uint32()
        XCTAssertEqual(num, 0x00010203)
    }

    func testUint32FromBytes() {
        var reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint32(fromBytes: 3), 258)
        XCTAssertFalse(reader.isFinished)

        reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint32(fromBytes: 4), 0x00010203)
        XCTAssertFalse(reader.isFinished)
    }

    func testUint16() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        let num = reader.uint16()
        XCTAssertEqual(num, 0x0001)
    }

    func testUint16FromBytes() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data)
        XCTAssertEqual(reader.uint16(fromBytes: 0), 0)
        XCTAssertEqual(reader.uint16(fromBytes: 2), 1)
        XCTAssertFalse(reader.isFinished)
    }

    func testNonZeroStartIndex() {
        let reader = BigEndianByteReader(data: BigEndianByteReaderTests.data[1...])
        XCTAssertEqual(reader.offset, 1)
        XCTAssertEqual(reader.uint16(), 0x0102)
        XCTAssertEqual(reader.offset, 3)
        XCTAssertEqual(reader.uint32(), 0x03040506)
        XCTAssertEqual(reader.offset, 7)
        XCTAssertEqual(reader.byte(), 0x07)
        XCTAssertEqual(reader.bytes(count: 1), [0x08])
    }

}
