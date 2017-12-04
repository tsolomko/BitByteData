// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import XCTest
@testable import BitByteDataTests

extension ByteReaderTests {
	static var allTests : [(String, ByteReaderTests -> () throws -> Void)] {
		return [
			("testByte", testByte),
		]
	}
}

XCTMain([
    testCase(ByteReaderTests.allTests),
])