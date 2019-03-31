// Copyright (c) 2018 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

extension Data {

    @inline(__always)
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.bindMemory(to: type)[0] }
    }

    @inline(__always)
    func toByteArray(_ count: Int) -> [UInt8] {
        return self.withUnsafeBytes { $0.map { $0 } }
    }

}
