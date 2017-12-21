// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol BitWriter {

    var buffer: [UInt8] { get }
    
    func write(bit: UInt8)

    func write(bits: [UInt8])

    func write(number: Int, bitsCount: Int)

    func finish()

}
