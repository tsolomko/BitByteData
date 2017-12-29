// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol BitReader: class {

    var isAligned: Bool { get }

    init(data: Data)

    func bits(count: Int) -> [UInt8]

    // TODO: Rename?
    func intFromBits(count: Int) -> Int

    func bit() -> Int

    // TODO: Describe, that it doesn't check for the end.
    func align()

    // TODO: Describe preconditions.

    func byte() -> UInt8

    func bytes(count: Int) -> [UInt8]

    func uint64() -> UInt64

    func uint32() -> UInt32

    func uint16() -> UInt16

}
