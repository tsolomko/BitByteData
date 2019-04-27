// Copyright (c) 2019 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol ByteReader: AnyObject {

    var size: Int { get }

    var data: Data { get }

    var offset: Int { get set }

    var isFinished: Bool { get }

    init(data: Data)

    func byte() -> UInt8

    func bytes(count: Int) -> [UInt8]

    func int(fromBytes count: Int) -> Int

    func uint64(fromBytes count: Int) -> UInt64

    func uint32(fromBytes count: Int) -> UInt32

    func uint16(fromBytes count: Int) -> UInt16

}

extension ByteReader {

    public var bytesLeft: Int {
        return { (data: Data, offset: Int) -> Int in
            return data.endIndex - offset
        } (self.data, self.offset)
    }

    public var bytesRead: Int {
        return { (data: Data, offset: Int) -> Int in
            return offset - data.startIndex
        } (self.data, self.offset)
    }
    
}
