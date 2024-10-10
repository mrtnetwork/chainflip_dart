import 'package:chainflip_dart/src/exception/exception.dart';

class AssetsConst {
  static const String eth = "Eth";
  static const String flip = "Flip";
  static const String usdc = "Usdc";
  static const String usdt = "Usdt";
  static const String dot = "Dot";
  static const String btc = "Btc";
  static const String arbEth = "ArbEth";
  static const String arbUsdc = "ArbUsdc";
  static const String sol = "Sol";
  static const String solUsdc = "SolUsdc";
}

class CfAssets {
  final String name;
  final String variant;
  final int variantId;

  const CfAssets._(
      {required this.variant, required this.name, required this.variantId});
  static const CfAssets flip =
      CfAssets._(name: 'FLIP', variant: "Flip", variantId: 2);
  static const CfAssets usdc =
      CfAssets._(name: 'USDC', variant: "Usdc", variantId: 3);
  static const CfAssets dot =
      CfAssets._(name: 'DOT', variant: "Dot", variantId: 4);
  static const CfAssets eth =
      CfAssets._(name: 'ETH', variant: "Eth", variantId: 1);
  static const CfAssets btc =
      CfAssets._(name: 'BTC', variant: 'Btc', variantId: 5);
  static const CfAssets usdt =
      CfAssets._(name: 'USDT', variant: "Usdt", variantId: 8);
  static const CfAssets sol =
      CfAssets._(name: "SOL", variant: 'Sol', variantId: 9);

  static List<CfAssets> get values => [flip, usdc, dot, eth, btc, usdt, sol];

  static CfAssets fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw DartCfPluginException("asset not found.",
            details: {"type": name}));
  }

  static CfAssets fromVariant(String? name) {
    return values.firstWhere((e) => e.variant == name,
        orElse: () => throw DartCfPluginException("asset not found.",
            details: {"type": name}));
  }
}
