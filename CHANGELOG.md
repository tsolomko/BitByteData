# Changelog

## 1.1.0

- Added converting from `ByteReader` initializers to `LsbBitReader` and `MsbBitReader`, as well as `BitReader` protocol.
- Added `bitsLeft` and `bitsRead` computed properties to `LsbBitReader` and `MsbBitReader`, as well as `BitReader`
  protocol.

## 1.0.2

- Fix several problems causing incorrect preconditions failures.

## 1.0.1

- Increased performance of `bit()`, `bits(count:)` and `int(fromBits:)` functions for both `LsbBitReader` and `MsbBitReader`.
- More consistent behaviour (precondition failures) for situtations when there is not enough data left.
- Small updates to documentation.

## 1.0.0

- `ByteReader` class for reading bytes.
- `BitReader` protocol, `LsbBitReader` and `MsbBitReader` classes for reading bits (and bytes).
- `BitWriter` protocol, `LsbBitWriter` and `MsbBitWriter` classes for writing bits (and bytes).
