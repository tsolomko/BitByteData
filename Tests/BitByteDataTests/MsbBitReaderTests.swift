// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class MsbBitReaderTests: XCTestCase {

    private static let data = Data(bytes: [0x5A, 0xD6])

    func testBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        var bits = bitReader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])

        bits = bitReader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 1, 1, 0])

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIntFromBits() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        var num = bitReader.intFromBits(count: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.intFromBits(count: 8)
        XCTAssertEqual(num, 214)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIsAligned() {
        let bitReader = MsbBitReader(data: MsbBitReaderTests.data)

        _ = bitReader.bits(count: 12)
        XCTAssertFalse(bitReader.isAligned)

        _ = bitReader.bits(count: 4)
        XCTAssertTrue(bitReader.isAligned)
    }

}