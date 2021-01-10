// Copyright (c) 2021 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

public protocol ByteReader: AnyObject {

    associatedtype BinarySource

    var size: Int { get }

    var source: BinarySource { get }

    var offset: Int { get set }

    init(source: BinarySource)

    func byte() -> UInt8

    func bytes(count: Int) -> [UInt8]

    func int(fromBytes count: Int) -> Int

    func uint64(fromBytes count: Int) -> UInt64

    func uint32(fromBytes count: Int) -> UInt32

    func uint16(fromBytes count: Int) -> UInt16

}

extension ByteReader {

    public init<T: BitReader>(_ bitReader: T) where T.BinarySource == Self.BinarySource {
        self.init(source: bitReader.source)
        self.offset = bitReader.offset
    }
    
}

extension ByteReader where BinarySource == Data {

    public var bytesLeft: Int {
        return { (data: BinarySource, offset: Int) -> Int in
            return data.endIndex - offset
        } (self.source, self.offset)
    }

    public var bytesRead: Int {
        return { (data: BinarySource, offset: Int) -> Int in
            return offset - data.startIndex
        } (self.source, self.offset)
    }

    public var isFinished: Bool {
        return { (data: BinarySource, offset: Int) -> Bool in
            return data.endIndex <= offset
        } (self.source, self.offset)
    }

    public func int(fromBytes count: Int) -> Int {
        if MemoryLayout<Int>.size == 8 {
            return Int(truncatingIfNeeded: self.uint64(fromBytes: count))
        } else if MemoryLayout<Int>.size == 4 {
            return Int(truncatingIfNeeded: self.uint32(fromBytes: count))
        } else {
            fatalError("Unknown Int bit width")
        }
    }

}
