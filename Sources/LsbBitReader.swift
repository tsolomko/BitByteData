// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/**
 A type that contains functions for reading `Data` bit-by-bit and byte-by-byte,
 assuming "LSB 0" bit numbering scheme.
 */
public final class LsbBitReader: ByteReader, BitReader {

    private var bitMask: UInt8 = 1

    /// True, if reader's BIT pointer is aligned with the BYTE border.
    public var isAligned: Bool {
        return self.bitMask == 1
    }

    /**
     Reads bit and returns it, advancing by one BIT position.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     */
    public func bit() -> UInt8 {
        let bit: UInt8 = self.data[self.offset] & self.bitMask > 0 ? 1 : 0

        if self.bitMask == 128 {
            self.offset += 1
            self.bitMask = 1
        } else {
            self.bitMask <<= 1
        }

        return bit
    }

    /**
     Reads `count` bits and returns them as a `Int` number, advancing by `count` BIT positions.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     */
    public func int(fromBits count: Int) -> Int {
        guard count > 0
            else { return 0 }

        var result = 0
        for i in 0..<count {
            let power = i

            let bit = self.data[self.offset] & self.bitMask > 0 ? 1 : 0
            result += (1 << power) * bit

            if self.bitMask == 128 {
                self.offset += 1
                self.bitMask = 1
            } else {
                self.bitMask <<= 1
            }
        }

        return result
    }

    /**
     Aligns reader's BIT pointer to the BYTE border, i.e. moves BIT pointer to the first BIT of the next BYTE.

     - Note: If reader is already aligned, then does nothing.
     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` AFTER calling this method
     to check if the end was reached.
     */
    public func align() {
        guard self.bitMask != 1
            else { return }

        self.bitMask = 1
        self.offset += 1
    }

    // MARK: ByteReader's methods.

    /**
     Reads byte and returns it, advancing by one BYTE position.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     - Precondition: Reader MUST be aligned.
     */
    public override func byte() -> UInt8 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.byte()
    }

    /**
     Reads `count` bytes and returns them as an array of `UInt8`, advancing by `count` BYTE positions.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     - Precondition: Reader MUST be aligned.
     */
    public override func bytes(count: Int) -> [UInt8] {
        precondition(isAligned, "BitReader is not aligned.")
        return super.bytes(count: count)
    }

    /**
     Reads 8 bytes and returns them as a `UInt64` number, advancing by 8 BYTE positions.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     - Precondition: Reader MUST be aligned.
     */
    public override func uint64() -> UInt64 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint64()
    }

    /**
     Reads 4 bytes and returns them as a `UInt32` number, advancing by 4 BYTE positions.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     - Precondition: Reader MUST be aligned.
     */
    public override func uint32() -> UInt32 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint32()
    }

    /**
     Reads 2 bytes and returns them as a `UInt16` number, advancing by 2 BYTE positions.

     - Warning: Doesn't check if there is any data left. It is advisable to use `isFinished` BEFORE calling this method
     to check if the end is reached.
     - Precondition: Reader MUST be aligned.
     */
    public override func uint16() -> UInt16 {
        precondition(isAligned, "BitReader is not aligned.")
        return super.uint16()
    }

}
