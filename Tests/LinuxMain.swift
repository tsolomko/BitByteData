// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
@testable import BitByteDataTests

extension ByteReaderTests {
	static var allTests: [(String, (ByteReaderTests) -> () throws -> Void)] {
		return [
			("testByte", testByte),
			("testIsFinished", testIsFinished),
			("testBytes", testBytes),
			("testUint64", testUint64),
			("testUint32", testUint32),
			("testUint16", testUint16)
		]
	}
}

extension LsbBitReaderTests {
	static var allTests: [(String, (LsbBitReaderTests) -> () throws -> Void)] {
		return [
			("testBit", testBit),
			("testBits", testBits),
			("testIntFromBits", testIntFromBits),
			("testIsAligned", testIsAligned),
			("testAlign", testAlign),
			("testBitReaderByte", testBitReaderByte),
			("testBitReaderBytes", testBitReaderBytes),
			("testBitReaderUint16", testBitReaderUint16)
		]
	}
}

extension MsbBitReaderTests {
	static var allTests: [(String, (MsbBitReaderTests) -> () throws -> Void)] {
		return [
			("testBit", testBit),
			("testBits", testBits),
			("testIntFromBits", testIntFromBits),
			("testIsAligned", testIsAligned),
			("testAlign", testAlign),
			("testBitReaderByte", testBitReaderByte),
			("testBitReaderBytes", testBitReaderBytes),
			("testBitReaderUint16", testBitReaderUint16)
		]
	}
}

extension LsbBitWriterTests {
	static var allTests: [(String, (LsbBitWriterTests) -> () throws -> Void)] {
		return [
			("testWriteBit", testWriteBit),
			("testWriteBitsArray", testWriteBitsArray),
			("testWriteNumber", testWriteNumber),
			("testAppendByte", testAppendByte),
			("testAlign", testAlign),
			("testIsAligned", testIsAligned),
			("testNamingConsistency", testNamingConsistency)
		]
	}
}

extension MsbBitWriterTests {
	static var allTests: [(String, (MsbBitWriterTests) -> () throws -> Void)] {
		return [
			("testWriteBit", testWriteBit),
			("testWriteBitsArray", testWriteBitsArray),
			("testWriteNumber", testWriteNumber),
			("testAppendByte", testAppendByte),
			("testAlign", testAlign),
			("testIsAligned", testIsAligned),
			("testNamingConsistency", testNamingConsistency)
		]
	}
}

XCTMain([
    testCase(ByteReaderTests.allTests),
	testCase(LsbBitReaderTests.allTests),
	testCase(MsbBitReaderTests.allTests),
	testCase(LsbBitWriterTests.allTests),
	testCase(MsbBitWriterTests.allTests)
])
