// Copyright (c) 2017 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol BitReader: class {

    var bitMask: UInt8 { get }

    var isAligned: Bool { get }

    init(data: Data)

    func bits(count: Int) -> [UInt8]

    func intFromBits(count: Int) -> Int

    func bit() -> Int

    func align()

}
