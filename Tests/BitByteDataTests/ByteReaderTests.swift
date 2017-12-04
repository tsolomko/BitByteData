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

        for i: UInt8 in 0...8 {
            let byte = byteReader.byte()
            XCTAssertEqual(byte, i)
        }
        XCTAssertTrue(byteReader.isAtTheEnd)

        byteReader.offset = 0

        for i: UInt8 in 0...4 {
            let byte = byteReader.byte()
            XCTAssertEqual(byte, i)
        }
        XCTAssertFalse(byteReader.isAtTheEnd)
    }

    func testBytes() {
        let byteReader = ByteReader(data: ByteReaderTests.data)
    }
    
}
