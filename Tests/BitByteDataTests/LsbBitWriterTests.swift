// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitWriterTests: XCTestCase {

    func testWriteBit() {
        let bitWriter = LsbBitWriter()

        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 0)
        bitWriter.write(bit: 1)
        bitWriter.write(bit: 1)
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([26]))
    }

    func testWriteBitsArray() {
        let bitWriter = LsbBitWriter()

        bitWriter.write(bits: [1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1])
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([83, 6]))
    }

    func testWriteNumber_SM() {
        let repr = SignedNumberRepresentation.signMagnitude
        let writer = LsbBitWriter()

        writer.write(number: 127, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 6, bitsCount: 4, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 56, bitsCount: 7, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3]))

        writer.write(number: -123, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 251]))
        writer.write(number: -56, bitsCount: 12, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 251, 56]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3, 251, 56, 8]))
        if Int.bitWidth == 64 {
            writer.write(number: Int.max, bitsCount: 64, representation: repr)
            writer.write(number: Int.min + 1, bitsCount: 64, representation: repr)
            XCTAssertEqual(writer.data, Data([127, 134, 3, 251, 56, 8,
                                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F,
                                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]))
        }
    }

    func testWriteNumber_1C() {
        let repr = SignedNumberRepresentation.oneComplement
        let writer = LsbBitWriter()

        writer.write(number: 127, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 6, bitsCount: 4, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 56, bitsCount: 7, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3]))

        writer.write(number: -123, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 132]))
        writer.write(number: -56, bitsCount: 12, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 132, 199]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3, 132, 199, 15]))
        if Int.bitWidth == 64 {
            writer.write(number: Int.max, bitsCount: 64, representation: repr)
            writer.write(number: Int.min + 1, bitsCount: 64, representation: repr)
            XCTAssertEqual(writer.data, Data([127, 134, 3, 132, 199, 15,
                                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F,
                                              0, 0, 0, 0, 0, 0, 0, 0x80]))
        }
    }


    func testWriteNumber_2C() {
        let repr = SignedNumberRepresentation.twoComplement
        let writer = LsbBitWriter()

        writer.write(number: 127, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 6, bitsCount: 4, representation: repr)
        XCTAssertEqual(writer.data, Data([127]))
        writer.write(number: 56, bitsCount: 7, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3]))

        writer.write(number: -123, bitsCount: 8, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 133]))
        writer.write(number: -56, bitsCount: 12, representation: repr)
        XCTAssertEqual(writer.data, Data([127, 134, 3, 133, 200]))
        writer.align()
        XCTAssertEqual(writer.data, Data([127, 134, 3, 133, 200, 15]))
        if Int.bitWidth == 64 {
            writer.write(number: Int.max, bitsCount: 64, representation: repr)
            writer.write(number: Int.min, bitsCount: 64, representation: repr)
            XCTAssertEqual(writer.data, Data([127, 134, 3, 133, 200, 15,
                                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F,
                                              0, 0, 0, 0, 0, 0, 0, 0x80]))
        }
    }

    func testWriteUnsignedNumber() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(unsignedNumber: UInt(UInt64.max), bitsCount: UInt64.bitWidth)

        let byteReader = LittleEndianByteReader(data: bitWriter.data)
        XCTAssertEqual(byteReader.uint64(), UInt64.max)
    }

    func testAppendByte() {
        let bitWriter = LsbBitWriter()

        bitWriter.append(byte: 0xCA)
        XCTAssertEqual(bitWriter.data, Data([0xCA]))
    }

    func testAlign() {
        let bitWriter = LsbBitWriter()

        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data())
        XCTAssertTrue(bitWriter.isAligned)
    }

    func testIsAligned() {
        let bitWriter = LsbBitWriter()

        bitWriter.write(bits: [0, 1, 0])
        XCTAssertFalse(bitWriter.isAligned)
        bitWriter.write(bits: [0, 1, 0, 1, 0])
        XCTAssertTrue(bitWriter.isAligned)

        bitWriter.write(bit: 0)
        XCTAssertFalse(bitWriter.isAligned)
        bitWriter.align()
        XCTAssertTrue(bitWriter.isAligned)
    }

    func testNamingConsistency() {
        let bitWriter = LsbBitWriter()
        bitWriter.write(number: 14582, bitsCount: 15)
        bitWriter.align()
        XCTAssertEqual(bitWriter.data, Data([0xF6, 0x38]))
        let bitReader = LsbBitReader(data: bitWriter.data)
        XCTAssertEqual(bitReader.int(fromBits: 15), 14582)
    }

}
