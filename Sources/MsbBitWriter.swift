// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public final class MsbBitWriter: BitWriter {

    public private(set) var data: Data = Data()

    private var bitMask: UInt8 = 128
    private var currentByte: UInt8 = 0

    public var isAligned: Bool {
        return self.bitMask == 128
    }

    public init() { }

    public func write(bit: UInt8) {
        precondition(bit <= 1, "A bit must be either 0 or 1.")

        self.currentByte += self.bitMask * bit

        if self.bitMask == 1 {
            self.bitMask = 128
            self.data.append(self.currentByte)
            self.currentByte = 0
        } else {
            self.bitMask >>= 1
        }
    }

    public func write(number: Int, bitsCount: Int) {
        var mask = 1 << (bitsCount - 1)
        for _ in 0..<bitsCount {
            self.write(bit: number & mask > 0 ? 1 : 0)
            mask >>= 1
        }
    }

    public func append(byte: UInt8) {
        precondition(isAligned, "BitWriter is not aligned.")
        self.data.append(byte)
    }

    public func align() {
        self.data.append(self.currentByte)
        self.currentByte = 0
        self.bitMask = 128
    }

}
