import XCTest

extension ByteReaderBenchmarks {
    static let __allTests = [
        ("testByte", testByte),
        ("testBytes", testBytes),
        ("testIntFromBytes", testIntFromBytes),
        ("testUint16", testUint16),
        ("testUint16FromBytes", testUint16FromBytes),
        ("testUint32", testUint32),
        ("testUint32FromBytes", testUint32FromBytes),
        ("testUint64", testUint64),
        ("testUint64FromBytes", testUint64FromBytes)
    ]
}

extension LsbBitReaderBenchmarks {
    static let __allTests = [
        ("testAdvance", testAdvance),
        ("testBit", testBit),
        ("testBits", testBits),
        ("testByteFromBits", testByteFromBits),
        ("testIntFromBits", testIntFromBits),
        ("testUint16FromBits", testUint16FromBits),
        ("testUint32FromBits", testUint32FromBits),
        ("testUint64FromBits", testUint64FromBits)
    ]
}

extension LsbBitWriterBenchmarks {
    static let __allTests = [
        ("testAppendByte", testAppendByte),
        ("testWriteBit", testWriteBit),
        ("testWriteNumberBitsCount", testWriteNumberBitsCount),
        ("testWriteUnsignedNumberBitsCount", testWriteUnsignedNumberBitsCount)
    ]
}

extension MsbBitReaderBenchmarks {
    static let __allTests = [
        ("testAdvance", testAdvance),
        ("testBit", testBit),
        ("testBits", testBits),
        ("testByteFromBits", testByteFromBits),
        ("testIntFromBits", testIntFromBits),
        ("testUint16FromBits", testUint16FromBits),
        ("testUint32FromBits", testUint32FromBits),
        ("testUint64FromBits", testUint64FromBits)
    ]
}

extension MsbBitWriterBenchmarks {
    static let __allTests = [
        ("testAppendByte", testAppendByte),
        ("testWriteBit", testWriteBit),
        ("testWriteNumberBitsCount", testWriteNumberBitsCount),
        ("testWriteUnsignedNumberBitsCount", testWriteUnsignedNumberBitsCount)
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ByteReaderBenchmarks.__allTests),
        testCase(LsbBitReaderBenchmarks.__allTests),
        testCase(LsbBitWriterBenchmarks.__allTests),
        testCase(MsbBitReaderBenchmarks.__allTests),
        testCase(MsbBitWriterBenchmarks.__allTests)
    ]
}
#endif
