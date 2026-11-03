/// Pembagian bilangan bulat dengan pembulatan setengah menjauhi nol.
int divRoundHalfAway(BigInt numerator, BigInt denominator) {
  assert(denominator > BigInt.zero);
  final q = numerator ~/ denominator;
  final r = numerator.remainder(denominator);
  final adjust = r.abs() * BigInt.two >= denominator
      ? BigInt.from(numerator.sign)
      : BigInt.zero;
  final result = q + adjust;
  if (!result.isValidInt) {
    throw RangeError('nilai melampaui batas int 64-bit');
  }
  return result.toInt();
}
