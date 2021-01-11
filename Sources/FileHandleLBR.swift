// Copyright (c) 2021 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

// Most of the used FileHandle APIs are available only on the latest versions of SDKs.
#if compiler(>=5.3)
@available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *)
public final class FileHandleLBR: ByteReader {

    public typealias BinarySource = FileHandle

    public var size: Int {
        fatalError("Unavailable")
    }

    public var source: FileHandle

    public var offset: Int {
        get {
            return try! Int(truncatingIfNeeded: self.source.offset())
        }
        set {
            try! self.source.seek(toOffset: UInt64(truncatingIfNeeded: newValue))
        }
    }

    public init(source: FileHandle) {
        self.source = source
    }

    public func byte() -> UInt8 {
        return try! self.source.read(upToCount: 1)![0]
    }

    public func bytes(count: Int) -> [UInt8] {
        return try! self.source.read(upToCount: count)!.toByteArray(count)
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

    public func uint64(fromBytes count: Int) -> UInt64 {
        return try! self.source.read(upToCount: count)!.toU64()
    }

    public func uint32(fromBytes count: Int) -> UInt32 {
        return try! self.source.read(upToCount: count)!.toU32()
    }

    public func uint16(fromBytes count: Int) -> UInt16 {
        return try! self.source.read(upToCount: count)!.toU16()
    }

}
#endif
