// Copyright (c) 2020 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

import Foundation

/// A type that contains functions for writing `Data` bit-by-bit (and byte-by-byte).
public protocol BitWriter {

    /// Data which contains writer's output (the last byte in progress is not included).
    var data: Data { get }

    /// True, if writer's BIT pointer is aligned with the BYTE border.
    var isAligned: Bool { get }

    /// Creates an instance for writing bits (and bytes).
    init()

    /// Writes `bit`, advancing by one BIT position.
    func write(bit: UInt8)

    /// Writes `bits`, advancing by `bits.count` BIT positions.
    func write(bits: [UInt8])

    /// Writes `number`, using and advancing by `bitsCount` BIT positions.
    func write(number: Int, bitsCount: Int)

    /// Writes signed `number`, using and advancing by `bitsCount` BIT positions.
    func write(signedNumber: Int, bitsCount: Int, representation: SignedNumberRepresentation)

    /// Writes unsigned `number`, using and advancing by `bitsCount` BIT positions.
    func write(unsignedNumber: UInt, bitsCount: Int)

    /// Writes `byte`, advancing by one BYTE position.
    func append(byte: UInt8)

    /**
     Aligns writer's BIT pointer to the BYTE border, i.e. moves BIT pointer to the first BIT of the next BYTE,
     filling all skipped BIT positions with zeros.
     */
    func align()

}

extension BitWriter {

    public func write(bits: [UInt8]) {
        for bit in bits {
            self.write(bit: bit)
        }
    }

    public func write(number: Int, bitsCount: Int) {
        self.write(unsignedNumber: UInt(bitPattern: number), bitsCount: bitsCount)
    }

    public func write(signedNumber: Int, bitsCount: Int, representation: SignedNumberRepresentation = .twoComplement) {
        var magnitude = signedNumber.magnitude
        switch representation {
        case .signMagnitude:
            assert(magnitude < (1 << (bitsCount - 1)),
                   "\(signedNumber) will be truncated when represented by Sign-Magnitude using \(bitsCount) bits")
            magnitude += signedNumber < 0 ? (1 << (bitsCount - 1)) : 0
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .oneComplement:
            assert(magnitude < (1 << (bitsCount - 1)),
                   "\(signedNumber) will be truncated when represented by 1-complement using \(bitsCount) bits")
            if signedNumber < 0 {
                magnitude = ~magnitude
            }
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .twoComplement:
            assert((signedNumber >= 0 && magnitude <= (1 << (bitsCount - 1)) - 1) ||
                (signedNumber < 0 && magnitude <= 1 << (bitsCount - 1)),
                   "\(signedNumber) will be truncated when represented by 2-complement using \(bitsCount) bits")
            if signedNumber < 0 {
                magnitude = ~magnitude &+ 1
            }
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .biased(let bias):
            assert(bias >= 0, "Bias cannot be less than zero.")
            assert(signedNumber >= -bias,
                   "\(signedNumber) is too small to be encoded by biased representation with \(bias) bias")
            let encoded = UInt(bitPattern: signedNumber &+ bias)
            let encodedUpperBound = bitsCount == UInt.bitWidth ? UInt.max : (1 << bitsCount) - 1
            assert(encoded <= encodedUpperBound,
                   "\(signedNumber) is too big to be encoded by biased representation with \(bias) bias using \(bitsCount) bits")
            self.write(unsignedNumber: encoded, bitsCount: bitsCount)
        case .radixNegativeTwo:
            let mask = UInt(truncatingIfNeeded: 0xAA_AA_AA_AA_AA_AA_AA_AA as UInt64)
            let unsignedBitPattern = UInt(bitPattern: signedNumber)
            let encoded = (unsignedBitPattern &+ mask) ^ mask
            let encodedBound = bitsCount == UInt.bitWidth ? UInt.max : ((1 << bitsCount) - 1)
            assert(encoded <= encodedBound,
                   "\(signedNumber) will be truncated when represented by -2 radix using \(bitsCount) bits")
            self.write(unsignedNumber: encoded, bitsCount: bitsCount)
        }
    }

}
