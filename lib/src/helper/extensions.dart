extension QuickBigInt on BigInt {
  String get toHexDecimal => "0x${toRadixString(16)}";
}
