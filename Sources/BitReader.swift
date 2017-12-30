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

    func bit() -> UInt8

    // TODO: Describe, that it doesn't check for the end.
    func align()

    // TODO: Describe preconditions.

    func byte() -> UInt8

    func bytes(count: Int) -> [UInt8]

    func uint64() -> UInt64

    func uint32() -> UInt32

    func uint16() -> UInt16

}

extension BitReader {

    public func bits(count: Int) -> [UInt8] {
        guard count > 0
            else { return [] }

        var array = [UInt8]()
        array.reserveCapacity(count)
        for _ in 0..<count {
            array.append(self.bit())
        }

        return array
    }

}
