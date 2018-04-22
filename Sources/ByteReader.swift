// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/// A type that contains functions for reading `Data` byte-by-byte.
public class ByteReader {

    /// Size of the `data` (in bytes).
    public let size: Int

    /// Data which is being read.
    public let data: Data

    /// Offset to the byte in `data` which will be read next.
    public var offset: Int

    /**
     True, if `offset` points at any position after the last byte in `data`.

     - Note: It generally means that all bytes have been read.
     */
    public var isFinished: Bool {
        return self.data.endIndex <= self.offset
    }

    /// Amount of bytes left to read.
    public var bytesLeft: Int {
        return self.data.endIndex - self.offset
    }

    /// Amount of bytes that were already read.
    public var bytesRead: Int {
        return self.offset - self.data.startIndex
    }

    /// Creates an instance for reading bytes from `data`.
    public init(data: Data) {
        self.size = data.count
        self.data = data
        self.offset = data.startIndex
    }

    /**
     Reads byte and returns it, advancing by one position.

     - Precondition: There MUST be enough data left.
     */
    public func byte() -> UInt8 {
        precondition(self.offset < self.data.endIndex)
        defer { self.offset += 1 }
        return self.data[self.offset]
    }

    /**
     Reads `count` bytes and returns them as an array of `UInt8`, advancing by `count` positions.

     - Precondition: Parameter `count` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func bytes(count: Int) -> [UInt8] {
        precondition(count >= 0)
        precondition(bytesLeft >= count)
        defer { self.offset += count }
        return self.data[self.offset..<self.offset + count].toArray(type: UInt8.self, count: count)
    }

    /**
     Reads `fromBytes` bytes and returns them as an `Int` number, advancing by `fromBytes` positions.

     - Precondition: Parameter `fromBytes` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func int(fromBytes count: Int) -> Int {
        precondition(count >= 0)
        precondition(bytesLeft >= count)
        // TODO: If uintX() could be force inlined or something in the future than probably it would make sense
        // to use them for `count` == 2, 4 or 8.
        var result = 0
        for i in 0..<count {
            result += Int(truncatingIfNeeded: self.data[self.offset]) << (8 * i)
            self.offset += 1
        }
        return result
    }

    /**
     Reads 8 bytes and returns them as a `UInt64` number, advancing by 8 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint64() -> UInt64 {
        precondition(bytesLeft >= 8)
        defer { self.offset += 8 }
        return self.data[self.offset..<self.offset + 8].to(type: UInt64.self)
    }

    /**
     Reads `fromBytes` bytes and returns them as an `UInt64` number, advancing by `fromBytes` positions.

     - Note: If it is known that `fromBytes` is exactly 8, then consider using `uint64()` function (without argument),
     since it has better performance in this situation.
     - Precondition: Parameter `fromBits` MUST be from `0..8` range, i.e. it MUST not exceed maximum possible amount of
     bytes that `UInt64` type can represent.
     - Precondition: There MUST be enough data left.
     */
    public func uint64(fromBytes count: Int) -> UInt64 {
        precondition(0...8 ~= count)
        precondition(bytesLeft >= count)
        var result = 0 as UInt64
        for i in 0..<count {
            result += UInt64(truncatingIfNeeded: self.data[self.offset]) << (8 * i)
            self.offset += 1
        }
        return result
    }

    /**
     Reads 4 bytes and returns them as a `UInt32` number, advancing by 4 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint32() -> UInt32 {
        precondition(bytesLeft >= 4)
        defer { self.offset += 4 }
        return self.data[self.offset..<self.offset + 4].to(type: UInt32.self)
    }

    /**
     Reads `fromBytes` bytes and returns them as an `UInt32` number, advancing by `fromBytes` positions.

     - Note: If it is known that `fromBytes` is exactly 4, then consider using `uint32()` function (without argument),
     since it has better performance in this situation.
     - Precondition: Parameter `fromBits` MUST be from `0..4` range, i.e. it MUST not exceed maximum possible amount of
     bytes that `UInt32` type can represent.
     - Precondition: There MUST be enough data left.
     */
    public func uint32(fromBytes count: Int) -> UInt32 {
        precondition(0...4 ~= count)
        precondition(bytesLeft >= count)
        var result = 0 as UInt32
        for i in 0..<count {
            result += UInt32(truncatingIfNeeded: self.data[self.offset]) << (8 * i)
            self.offset += 1
        }
        return result
    }

    /**
     Reads 2 bytes and returns them as a `UInt16` number, advancing by 2 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint16() -> UInt16 {
        precondition(bytesLeft >= 2)
        defer { self.offset += 2 }
        return self.data[self.offset..<self.offset + 2].to(type: UInt16.self)
    }

    /**
     Reads `fromBytes` bytes and returns them as an `UInt16` number, advancing by `fromBytes` positions.

     - Note: If it is known that `fromBytes` is exactly 2, then consider using `uint16()` function (without argument),
     since it has better performance in this situation.
     - Precondition: Parameter `fromBits` MUST be from `0..2` range, i.e. it MUST not exceed maximum possible amount of
     bytes that `UInt16` type can represent.
     - Precondition: There MUST be enough data left.
     */
    public func uint16(fromBytes count: Int) -> UInt16 {
        precondition(0...2 ~= count)
        precondition(bytesLeft >= count)
        var result = 0 as UInt16
        for i in 0..<count {
            result += UInt16(truncatingIfNeeded: self.data[self.offset]) << (8 * i)
            self.offset += 1
        }
        return result
    }

}
