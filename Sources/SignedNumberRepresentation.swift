// Copyright (c) 2021 Timofey Solomko
// Licensed under MIT License
//
// See LICENSE for license information

public enum SignedNumberRepresentation {
    case signMagnitude
    case oneComplement
    case twoComplement
    case biased(bias: Int)
    case radixNegativeTwo
}
