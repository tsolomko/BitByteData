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
}
