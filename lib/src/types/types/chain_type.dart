import 'package:chainflip_dart/src/exception/exception.dart';
import 'assets.dart';

class CfChain {
  final String name;
  final String variantName;
  final List<CfAssets> assets;
  final CfAssets gasAsset;
  final int variantId;
  final double blockTimeSeconds;

  const CfChain._(
      {required this.name,
      required this.variantName,
      required this.assets,
      required this.gasAsset,
      required this.variantId,
      required this.blockTimeSeconds});

  static const CfChain bitcoin = CfChain._(
    name: 'Bitcoin',
    variantName: "Btc",
    assets: [CfAssets.btc],
    gasAsset: CfAssets.btc,
    variantId: 3,
    blockTimeSeconds: 10 * 60,
  );
  static const CfChain ethereum = CfChain._(
    name: "Ethereum",
    variantName: "Eth",
    assets: [CfAssets.eth, CfAssets.flip, CfAssets.usdc, CfAssets.usdt],
    gasAsset: CfAssets.eth,
    variantId: 1,
    blockTimeSeconds: 12,
  );
  static const CfChain polkadot = CfChain._(
    name: "Polkadot",
    variantName: "Dot",
    assets: [CfAssets.dot],
    gasAsset: CfAssets.dot,
    variantId: 2,
    blockTimeSeconds: 6,
  );
  static const CfChain arbitrum = CfChain._(
    name: "Arbitrum",
    variantName: "Arb",
    assets: [CfAssets.eth, CfAssets.usdc],
    gasAsset: CfAssets.eth,
    variantId: 4,
    blockTimeSeconds: 0.26,
  );
  static const CfChain solana = CfChain._(
    name: "Solana",
    variantName: "Sol",
    assets: [CfAssets.sol, CfAssets.usdc],
    gasAsset: CfAssets.sol,
    variantId: 5,
    blockTimeSeconds: (400 + 800) / 2 / 1000,
  );

  static List<CfChain> get values =>
      [bitcoin, ethereum, polkadot, arbitrum, solana];
  static CfChain fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw DartCfPluginException("chain not found.",
            details: {"type": name}));
  }

  static CfChain fromVariant(String? name) {
    return values.firstWhere((e) => e.variantName == name,
        orElse: () => throw DartCfPluginException("chain not found.",
            details: {"type": name}));
  }

  String getChainVariant() {
    return variantName;
  }

  int getChainVariantId() {
    return variantId;
  }

  CfAssets validateChainAsset(CfAssets asset) {
    if (!assets.contains(asset)) {
      throw DartCfPluginException("Asset does not exist.",
          details: {"chain": name, "asset": asset.name});
    }
    return asset;
  }

  String getAssetVariant(CfAssets asset) {
    validateChainAsset(asset);
    switch (this) {
      case CfChain.ethereum:
      case CfChain.bitcoin:
      case CfChain.polkadot:
        return asset.variant;
      case CfChain.arbitrum:
        return variantName + asset.variant;
      default:
        if (asset == gasAsset) {
          return asset.variant;
        }
        return variantName + asset.variant;
    }
  }

  int getAssetVariantId(CfAssets asset) {
    validateChainAsset(asset);
    switch (this) {
      case CfChain.ethereum:
      case CfChain.bitcoin:
      case CfChain.polkadot:
        return asset.variantId;
      case CfChain.arbitrum:
        switch (asset) {
          case CfAssets.eth:
            return 6;
          case CfAssets.usdc:
            return 7;
        }
        break;
      case CfChain.solana:
        switch (asset) {
          case CfAssets.sol:
            return asset.variantId;
          case CfAssets.usdc:
            return 10;
        }
        break;
      default:
        break;
    }
    throw DartCfPluginException("Asset does not exist.",
        details: {"chain": name, "asset": asset.name});
  }

  @override
  String toString() {
    return "Chain.$name";
  }
}
