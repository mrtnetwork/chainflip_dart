import 'package:blockchain_utils/utils/utils.dart';

class CfHelper {
  static const int perseveranceSubstrateSS58Format = 2112;

  static final BigRational _solanaDecimal = BigRational(BigInt.from(10).pow(9));
  static BigInt solToLamports(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _solanaDecimal).toBigInt();
  }

  static String lamportsToSol(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _solanaDecimal).toDecimal(digits: 12);
  }

  static final BigRational _usdcPrecision = BigRational(BigInt.from(10).pow(6));

  static BigInt usdcToBig(String amount) {
    final parse = BigRational.parseDecimal(amount);
    return (parse * _usdcPrecision).toBigInt();
  }

  static String bigToUsdc(BigInt amount) {
    final parse = BigRational(amount);
    return (parse / _usdcPrecision).toDecimal(digits: 12);
  }

  static BigInt priceToBig(String amount, int decimals) {
    final BigRational precision = BigRational(BigInt.from(10).pow(decimals));
    final parse = BigRational.parseDecimal(amount);
    return (parse * precision).toBigInt();
  }

  static String bigToPrice(BigInt amount, int decimals) {
    final BigRational precision = BigRational(BigInt.from(10).pow(decimals));
    final parse = BigRational(amount);
    return (parse / precision).toDecimal(digits: 12);
  }
}
