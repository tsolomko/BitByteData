// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
import BitByteData

class LsbBitReaderTests: XCTestCase {

    private static let data = Data([0x5A, 0xD6, 0x57, 0x14, 0xAB, 0xCC, 0x2D, 0x88, 0xEA, 0x00])

    func testAdvance() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance()
        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance()
        bitReader.advance()
        XCTAssertEqual(bitReader.bit(), 0)
        bitReader.advance(by: 4)
        XCTAssertEqual(bitReader.bit(), 1)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testBit() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bit(), 1)
        XCTAssertEqual(bitReader.bit(), 1)

        XCTAssertFalse(bitReader.isAligned)
    }

    func testBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bits(count: 0), [])
        var bits = bitReader.bits(count: 3)
        XCTAssertEqual(bits, [0, 1, 0])

        bits = bitReader.bits(count: 8)
        XCTAssertEqual(bits, [1, 1, 0, 1, 0, 0, 1, 1])

        XCTAssertFalse(bitReader.isAligned)
    }

    func testSignedIntFromBits_SM() {
        let repr = SignedNumberRepresentation.signMagnitude
        var reader = LsbBitReader(data: Data([127, 160, 15, 128]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 127)
        XCTAssertEqual(reader.signedInt(fromBits: 3, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: 4, representation: repr), 4)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 5, representation: repr), -15)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), 0)
        XCTAssertTrue(reader.isAligned)

        reader = LsbBitReader(data: Data([251, 56, 8]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), -123)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -56)
    }

    func testSignedIntFromBits_1C() {
        let repr = SignedNumberRepresentation.oneComplement
        var reader = LsbBitReader(data: Data([127, 160, 15, 128]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 127)
        XCTAssertEqual(reader.signedInt(fromBits: 3, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: 4, representation: repr), 4)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 5, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -2047)
        XCTAssertTrue(reader.isAligned)

        reader = LsbBitReader(data: Data([132, 199, 15]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), -123)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -56)
    }

    func testSignedIntFromBits_2C() {
        let repr = SignedNumberRepresentation.twoComplement
        var reader = LsbBitReader(data: Data([127, 160, 15, 128]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 127)
        XCTAssertEqual(reader.signedInt(fromBits: 3, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: 4, representation: repr), 4)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 5, representation: repr), -1)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -2048)
        XCTAssertTrue(reader.isAligned)

        reader = LsbBitReader(data: Data([133, 200, 15]))
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), -123)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -56)
    }

    func testSignedIntFromBits_Biased_E127() {
        let repr = SignedNumberRepresentation.biased(bias: 127)
        let reader: LsbBitReader
        if MemoryLayout<Int>.size == 8 {
            reader = LsbBitReader(data: Data([253, 133, 183, 127, 4, 71, 0, 0x7E, 0, 0, 0, 0, 0, 0, 0x80]))
        } else if MemoryLayout<Int>.size == 4 {
            reader = LsbBitReader(data: Data([253, 133, 183, 127, 4, 71, 0, 0x7E, 0, 0, 0x80]))
        } else {
            XCTFail("Unsupported Int bit width.")
            return
        }
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 126)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 6)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 56)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), -123)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), -56)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertEqual(reader.signedInt(fromBits: Int.bitWidth, representation: repr), Int.max)
    }

    func testSignedIntFromBits_Biased_E3() {
        let repr = SignedNumberRepresentation.biased(bias: 3)
        let reader: LsbBitReader
        if MemoryLayout<Int>.size == 8 {
            reader = LsbBitReader(data: Data([240, 129, 9, 176, 3, 3, 2, 0, 0, 0, 0, 0, 0, 0x80]))
        } else if MemoryLayout<Int>.size == 4 {
            reader = LsbBitReader(data: Data([240, 129, 9, 176, 3, 3, 2, 0, 0, 0x80]))
        } else {
            XCTFail("Unsupported Int bit width.")
            return
        }
        XCTAssertEqual(reader.signedInt(fromBits: 4, representation: repr), -3)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 4, representation: repr), 12)
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 126)
        XCTAssertEqual(reader.signedInt(fromBits: 12, representation: repr), 6)
        XCTAssertFalse(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 6, representation: repr), 56)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 8, representation: repr), 0)
        XCTAssertEqual(reader.signedInt(fromBits: Int.bitWidth, representation: repr), Int.max)
    }

    func testSignedIntFromBits_Biased_E1023() {
        let repr = SignedNumberRepresentation.biased(bias: 1023)
        let reader: LsbBitReader
        if MemoryLayout<Int>.size == 8 {
            reader = LsbBitReader(data: Data([0, 0, 255, 3, 0xFE, 3, 0, 0, 0, 0, 0, 0x80]))
        } else if MemoryLayout<Int>.size == 4 {
            reader = LsbBitReader(data: Data([0, 0, 255, 3, 0xFE, 3, 0, 0x80]))
        } else {
            XCTFail("Unsupported Int bit width.")
            return
        }
        XCTAssertEqual(reader.signedInt(fromBits: 11, representation: repr), -1023)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: 11, representation: repr), 0)
        XCTAssertFalse(reader.isAligned)
        reader.align()
        XCTAssertTrue(reader.isAligned)
        XCTAssertEqual(reader.signedInt(fromBits: Int.bitWidth, representation: repr), Int.max)
    }

    func testByteFromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.byte(fromBits: 0), 0)
        var num = bitReader.byte(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.byte(fromBits: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.byte(fromBits: 8), 0x57)
    }

    func testUint16FromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint16(fromBits: 0), 0)
        var num = bitReader.uint16(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint16(fromBits: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint16(fromBits: 16), 0x14_57)
    }

    func testUint32FromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint32(fromBits: 0), 0)
        var num = bitReader.uint32(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint32(fromBits: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint32(fromBits: 32), 0xCC_AB_14_57)
    }

    func testUint64FromBits() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint64(fromBits: 0), 0)
        var num = bitReader.uint64(fromBits: 3)
        XCTAssertEqual(num, 2)

        num = bitReader.uint64(fromBits: 8)
        XCTAssertEqual(num, 203)

        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        XCTAssertEqual(bitReader.uint64(fromBits: 64), 0x00_EA_88_2D_CC_AB_14_57)
    }

    func testIsAligned() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 12)
        XCTAssertFalse(bitReader.isAligned)

        _ = bitReader.bits(count: 4)
        XCTAssertTrue(bitReader.isAligned)
    }

    func testAlign() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertFalse(bitReader.isAligned)

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)

        _ = bitReader.byte()

        bitReader.align()
        XCTAssertTrue(bitReader.isAligned)
    }

    func testBytesLeft() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesLeft, 10)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesLeft, 9)
        _ = bitReader.byte()
        XCTAssertEqual(bitReader.bytesLeft, 8)
        bitReader.offset = bitReader.data.endIndex - 1
        XCTAssertEqual(bitReader.bytesLeft, 1)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesLeft, 1)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesLeft, 0)
    }

    func testBytesRead() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesRead, 0)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesRead, 1)
        _ = bitReader.byte()
        XCTAssertEqual(bitReader.bytesRead, 2)
        bitReader.offset = bitReader.data.endIndex - 1
        XCTAssertEqual(bitReader.bytesRead, 9)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bytesRead, 9)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bytesRead, 10)
    }

    func testBitReaderByte() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        var byte = bitReader.byte()
        XCTAssertEqual(byte, 0x5A)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)

        byte = bitReader.byte()
        XCTAssertEqual(byte, 0xD6)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderBytes() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bytes(count: 0), [])
        let bytes = bitReader.bytes(count: 2)
        XCTAssertEqual(bytes, [0x5A, 0xD6])
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderIntFromBytes() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)
        XCTAssertEqual(bitReader.int(fromBytes: 0), 0)
        XCTAssertEqual(bitReader.int(fromBytes: 2), 54874)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderUint16() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint16(fromBytes: 0), 0)
        let num = bitReader.uint16()
        XCTAssertEqual(num, 54874)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderUint32FromBytes() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.uint32(fromBytes: 0), 0)
        let num = bitReader.uint32(fromBytes: 3)
        XCTAssertEqual(num, 5756506)
        XCTAssertTrue(bitReader.isAligned)
        XCTAssertFalse(bitReader.isFinished)
    }

    func testBitReaderNonZeroStartIndex() {
        var bitReader = LsbBitReader(data: LsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.byte(), 0xD6)
        bitReader = LsbBitReader(data: LsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.bytes(count: 1), [0xD6])
        bitReader = LsbBitReader(data: LsbBitReaderTests.data[1...])
        XCTAssertEqual(bitReader.offset, 1)
        XCTAssertEqual(bitReader.bit(), 0)
        XCTAssertEqual(bitReader.bits(count: 3), [1, 1, 0])
        XCTAssertEqual(bitReader.signedInt(fromBits: 4), -3)
    }

    func testConvertedByteReader() {
        let byteReader = LittleEndianByteReader(data: LsbBitReaderTests.data)
        _ = byteReader.byte()

        var bitReader = LsbBitReader(byteReader)
        XCTAssertEqual(bitReader.byte(), 0xD6)
        XCTAssertEqual(bitReader.bits(count: 4), [1, 1, 1, 0])
        XCTAssertEqual(bitReader.signedInt(fromBits: 4), 5)

        bitReader = LsbBitReader(byteReader)
        XCTAssertEqual(bitReader.bits(count: 4), [0, 1, 1, 0])
        XCTAssertEqual(bitReader.signedInt(fromBits: 4), -3)
    }

    func testBitsLeft() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bitsLeft, 80)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsLeft, 76)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsLeft, 72)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bitsLeft, 70)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bitsLeft, 64)
        _ = bitReader.uint64(fromBits: 64)
        XCTAssertEqual(bitReader.bitsLeft, 0)
    }

    func testBitsRead() {
        let bitReader = LsbBitReader(data: LsbBitReaderTests.data)

        XCTAssertEqual(bitReader.bitsRead, 0)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsRead, 4)
        _ = bitReader.bits(count: 4)
        XCTAssertEqual(bitReader.bitsRead, 8)
        _ = bitReader.bits(count: 2)
        XCTAssertEqual(bitReader.bitsRead, 10)
        _ = bitReader.bits(count: 6)
        XCTAssertEqual(bitReader.bitsRead, 16)
    }

}
