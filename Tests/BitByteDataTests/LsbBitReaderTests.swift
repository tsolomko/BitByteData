// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitReaderTests: XCTestCase {

    private static let data = Data(bytes: [0x5A, 0xD6])

    func testBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var bits = bitReader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])

        bits = bitReader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 0, 1, 1])

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIntFromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var num = bitReader.intFromBits(count: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.intFromBits(count: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testIsAligned() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 12)
        XCTAssertFalse(bitReader.isAligned)

        _ = bitReader.bits(count: 4)
        XCTAssertTrue(bitReader.isAligned)
    }

}