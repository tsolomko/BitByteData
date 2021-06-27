// Copyright (c) 2021 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

public enum SignedNumberRepresentation {

    case signMagnitude
    case oneComplementNegatives
    case twoComplementNegatives
    case biased(bias: Int)
    case radixNegativeTwo

    // Generally speaking, there is a natural limit of the maximum and minimum values that Swift's Int type can hold.
    // So when the bitsCount matches the bit width of the Int type we need to be careful.

    public func minRepresentableNumber(bitsCount: Int) -> Int {
        precondition(bitsCount > 0)

        switch self {
        case .signMagnitude:
            fallthrough
        case .oneComplementNegatives:
            return bitsCount >= Int.bitWidth ? Int.min : -(1 << (bitsCount - 1) - 1)
        case .twoComplementNegatives:
            // Technically, we don't need to be extremely careful in the 2's-complement case, since it is the
            // representation used internally by Swift, however, in practice, we still get arithmetic overflow
            // in the bitsCount == Int.bitWidth case, if we use the formula, so we check for this case specifically.
            return bitsCount >= Int.bitWidth ? Int.min : -(1 << (bitsCount - 1))
        case .biased(let bias):
            precondition(bias >= 0)
            return -bias
        case .radixNegativeTwo:
            if bitsCount >= Int.bitWidth {
                return Int.min
            }
            // Minimum corresponds to all of the odd bits being set.
            var result = 0
            var mult = 2
            for _ in stride(from: 1, to: bitsCount, by: 2) {
                result -= mult
                mult *= 4
            }
            return result
        }
    }

    public func maxRepresentableNumber(bitsCount: Int) -> Int {
        precondition(bitsCount > 0)

        switch self {
        case .signMagnitude:
            fallthrough
        case .oneComplementNegatives:
            fallthrough
        case .twoComplementNegatives:
            return bitsCount >= Int.bitWidth ? Int.max : 1 << (bitsCount - 1) - 1
        case .biased(let bias):
            precondition(bias >= 0)
            return bitsCount >= Int.bitWidth ? Int.max - bias : (1 << bitsCount) - 1 - bias
        case .radixNegativeTwo:
            // Maximum corresponds to all of the even bits being set.
            var result = 0
            var mult = 1
            for _ in stride(from: 0, to: bitsCount, by: 2) {
                result += mult
                let (newMult, overflow) = mult.multipliedReportingOverflow(by: 4)
                if overflow {
                    // This means that we reached the Int.max limit.
                    break
                }
                mult = newMult
            }
            return result
        }
    }

}
