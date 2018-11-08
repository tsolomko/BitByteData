import XCTest

extension ByteReaderTests {
    static let __allTests = [
        ("testByte", testByte),
        ("testBytes", testBytes),
        ("testBytesLeft", testBytesLeft),
        ("testBytesRead", testBytesRead),
        ("testIntFromBytes", testIntFromBytes),
        ("testIsFinished", testIsFinished),
        ("testNonZeroStartIndex", testNonZeroStartIndex),
        ("testUint16", testUint16),
        ("testUint16FromBytes", testUint16FromBytes),
        ("testUint32", testUint32),
        ("testUint32FromBytes", testUint32FromBytes),
        ("testUint64", testUint64),
        ("testUint64FromBytes", testUint64FromBytes)
    ]
}

extension LsbBitReaderTests {
    static let __allTests = [
        ("testAdvance", testAdvance),
        ("testAlign", testAlign),
        ("testBit", testBit),
        ("testBitReaderByte", testBitReaderByte),
        ("testBitReaderBytes", testBitReaderBytes),
        ("testBitReaderIntFromBytes", testBitReaderIntFromBytes),
        ("testBitReaderNonZeroStartIndex", testBitReaderNonZeroStartIndex),
        ("testBitReaderUint16", testBitReaderUint16),
        ("testBitReaderUint32FromBytes", testBitReaderUint32FromBytes),
        ("testBits", testBits),
        ("testBitsLeft", testBitsLeft),
        ("testBitsRead", testBitsRead),
        ("testByteFromBits", testByteFromBits),
        ("testBytesLeft", testBytesLeft),
        ("testBytesRead", testBytesRead),
        ("testConvertedByteReader", testConvertedByteReader),
        ("testIntFromBits", testIntFromBits),
        ("testIsAligned", testIsAligned),
        ("testUint16FromBits", testUint16FromBits),
        ("testUint32FromBits", testUint32FromBits),
        ("testUint64FromBits", testUint64FromBits)
    ]
}

extension LsbBitWriterTests {
    static let __allTests = [
        ("testAlign", testAlign),
        ("testAppendByte", testAppendByte),
        ("testIsAligned", testIsAligned),
        ("testNamingConsistency", testNamingConsistency),
        ("testWriteBit", testWriteBit),
        ("testWriteBitsArray", testWriteBitsArray),
        ("testWriteNumber", testWriteNumber),
        ("testWriteUnsignedNumber", testWriteUnsignedNumber)
    ]
}

extension MsbBitReaderTests {
    static let __allTests = [
        ("testAdvance", testAdvance),
        ("testAlign", testAlign),
        ("testBit", testBit),
        ("testBitReaderByte", testBitReaderByte),
        ("testBitReaderBytes", testBitReaderBytes),
        ("testBitReaderIntFromBytes", testBitReaderIntFromBytes),
        ("testBitReaderNonZeroStartIndex", testBitReaderNonZeroStartIndex),
        ("testBitReaderUint16", testBitReaderUint16),
        ("testBitReaderUint32FromBytes", testBitReaderUint32FromBytes),
        ("testBits", testBits),
        ("testBitsLeft", testBitsLeft),
        ("testBitsRead", testBitsRead),
        ("testByteFromBits", testByteFromBits),
        ("testBytesLeft", testBytesLeft),
        ("testBytesRead", testBytesRead),
        ("testConvertedByteReader", testConvertedByteReader),
        ("testIntFromBits", testIntFromBits),
        ("testIsAligned", testIsAligned),
        ("testUint16FromBits", testUint16FromBits),
        ("testUint32FromBits", testUint32FromBits),
        ("testUint64FromBits", testUint64FromBits)
    ]
}

extension MsbBitWriterTests {
    static let __allTests = [
        ("testAlign", testAlign),
        ("testAppendByte", testAppendByte),
        ("testIsAligned", testIsAligned),
        ("testNamingConsistency", testNamingConsistency),
        ("testWriteBit", testWriteBit),
        ("testWriteBitsArray", testWriteBitsArray),
        ("testWriteNumber", testWriteNumber),
        ("testWriteUnsignedNumber", testWriteUnsignedNumber)
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ByteReaderTests.__allTests),
        testCase(LsbBitReaderTests.__allTests),
        testCase(LsbBitWriterTests.__allTests),
        testCase(MsbBitReaderTests.__allTests),
        testCase(MsbBitWriterTests.__allTests)
    ]
}
#endif
