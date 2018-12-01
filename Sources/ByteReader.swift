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
    public var offset: Int {
        get {
            return self._offset + self.data.startIndex
        }
        set {
            self._offset = newValue - self.data.startIndex
        }
    }

    var _offset: Int

    var ptr: UnsafeBufferPointer<UInt8>

    /**
     True, if `offset` points at any position after the last byte in `data`.

     - Note: It generally means that all bytes have been read.
     */
    public var isFinished: Bool {
        return self.size <= self._offset
    }

    /// Amount of bytes left to read.
    public var bytesLeft: Int {
        return self.size - self._offset
    }

    /// Amount of bytes that were already read.
    public var bytesRead: Int {
        return self._offset
    }

    /// Creates an instance for reading bytes from `data`.
    public init(data: Data) {
        self.size = data.count
        self.data = data
        self._offset = 0
        self.ptr = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> UnsafeBufferPointer<UInt8> in
            return UnsafeBufferPointer<UInt8>(start: ptr, count: data.count)
        }
    }

    /**
     Reads byte and returns it, advancing by one position.

     - Precondition: There MUST be enough data left.
     */
    public func byte() -> UInt8 {
        precondition(self._offset < self.size)
        defer { self._offset += 1 }
        return self.ptr[self._offset]
    }

    /**
     Reads `count` bytes and returns them as an array of `UInt8`, advancing by `count` positions.

     - Precondition: Parameter `count` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func bytes(count: Int) -> [UInt8] {
        precondition(count >= 0)
        precondition(bytesLeft >= count)
        var result = [UInt8]()
        result.reserveCapacity(count)
        for _ in 0..<count {
            result.append(self.ptr[self._offset])
            self._offset += 1
        }
        return result
    }

    /**
     Reads `fromBytes` bytes and returns them as an `Int` number, advancing by `fromBytes` positions.

     - Precondition: Parameter `fromBytes` MUST not be less than 0.
     - Precondition: There MUST be enough data left.
     */
    public func int(fromBytes count: Int) -> Int {
        precondition(count >= 0)
        // TODO: If uintX() could be force inlined or something in the future then probably it would make sense
        // to use them for `count` == 2, 4 or 8.
        var result = 0
        for i in 0..<count {
            result += Int(truncatingIfNeeded: self.ptr[self._offset]) << (8 * i)
            self._offset += 1
        }
        return result
    }

    /**
     Reads 8 bytes and returns them as a `UInt64` number, advancing by 8 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint64() -> UInt64 {
        return self.uint64(fromBytes: 8)
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
            result += UInt64(truncatingIfNeeded: self.ptr[self._offset]) << (8 * i)
            self._offset += 1
        }
        return result
    }

    /**
     Reads 4 bytes and returns them as a `UInt32` number, advancing by 4 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint32() -> UInt32 {
        return self.uint32(fromBytes: 4)
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
            result += UInt32(truncatingIfNeeded: self.ptr[self._offset]) << (8 * i)
            self._offset += 1
        }
        return result
    }

    /**
     Reads 2 bytes and returns them as a `UInt16` number, advancing by 2 positions.

     - Precondition: There MUST be enough data left.
     */
    public func uint16() -> UInt16 {
        return self.uint16(fromBytes: 2)
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
            result += UInt16(truncatingIfNeeded: self.ptr[self._offset]) << (8 * i)
            self._offset += 1
        }
        return result
    }

}
