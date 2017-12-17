// Copyright (c) 2017 Timofey Solomko
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
        XCTAssertFalse(byteReader.isAtTheEnd)
    }

    func testAtTheEnd() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        byteReader.offset = 9
        XCTAssertTrue(byteReader.isAtTheEnd)
    }

    func testBytes() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let bytes = byteReader.bytes(count: 4)
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03])
    }

    func testUint64() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint64()
        XCTAssertEqual(num, 0x0706050403020100)
    }

    func testUint32() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint32()
        XCTAssertEqual(num, 0x03020100)
    }

    func testUint16() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
        let num = byteReader.uint16()
        XCTAssertEqual(num, 0x0100)
    }

}
