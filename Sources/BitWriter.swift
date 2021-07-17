// Copyright (c) 2021 Timofey Solomko
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
        precondition(0...Int.bitWidth ~= bitsCount)
        self.write(unsignedNumber: UInt(bitPattern: number), bitsCount: bitsCount)
    }

    public func write(signedNumber: Int, bitsCount: Int, representation: SignedNumberRepresentation = .twoComplementNegatives) {
        precondition(signedNumber >= representation.minRepresentableNumber(bitsCount: bitsCount) &&
                        signedNumber <= representation.maxRepresentableNumber(bitsCount: bitsCount),
                     "\(signedNumber) cannot be represented by \(representation) using \(bitsCount) bits")

        var magnitude = signedNumber.magnitude
        switch representation {
        case .signMagnitude:
            magnitude += signedNumber < 0 ? (1 << (bitsCount - 1)) : 0
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .oneComplementNegatives:
            if signedNumber < 0 {
                magnitude = ~magnitude
            }
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .twoComplementNegatives:
            if signedNumber < 0 {
                magnitude = ~magnitude &+ 1
            }
            self.write(unsignedNumber: magnitude, bitsCount: bitsCount)
        case .biased(let bias):
            precondition(bias >= 0, "Bias cannot be less than zero.")
            self.write(unsignedNumber: UInt(bitPattern: signedNumber &+ bias), bitsCount: bitsCount)
        case .radixNegativeTwo:
            let mask = UInt(truncatingIfNeeded: 0xAA_AA_AA_AA_AA_AA_AA_AA as UInt64)
            let unsignedBitPattern = UInt(bitPattern: signedNumber)
            let encoded = (unsignedBitPattern &+ mask) ^ mask
            self.write(unsignedNumber: encoded, bitsCount: bitsCount)
        }
    }

}
