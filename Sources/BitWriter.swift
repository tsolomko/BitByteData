// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol BitWriter {

    // TODO: Replace with `data`?
    var buffer: [UInt8] { get }

    init()

    // TODO: isAligned OR bitMask?
    
    func write(bit: UInt8)

    func write(bits: [UInt8])

    // TODO: Describe, what will happen if `bitsCount` is smaller than actual amount of `number`'s bits.
    // TODO: Describe, that `number` is processed in the same order as `BitWriter`'s.
    func write(number: Int, bitsCount: Int)

    // TODO: Describe, that it doesn't check if it actually needs to finish.
    func finish()

}
