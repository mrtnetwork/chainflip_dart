import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:chainflip_dart/src/api/cf/utils/utils.dart';
import 'package:chainflip_dart/src/types/types.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class AssetAndChain {
  final CfAssets asset;
  final CfChain chain;
  const AssetAndChain._({required this.asset, required this.chain});
  factory AssetAndChain.solana({CfAssets asset = CfAssets.sol}) {
    return AssetAndChain._(
        asset: CfChain.solana.validateChainAsset(asset), chain: CfChain.solana);
  }

  factory AssetAndChain.bitcoin() {
    return AssetAndChain._(asset: CfAssets.btc, chain: CfChain.bitcoin);
  }

  factory AssetAndChain.ethereum({CfAssets asset = CfAssets.eth}) {
    return AssetAndChain._(
        asset: CfChain.ethereum.validateChainAsset(asset),
        chain: CfChain.ethereum);
  }

  factory AssetAndChain.polkadot() {
    return AssetAndChain._(asset: CfAssets.dot, chain: CfChain.polkadot);
  }

  factory AssetAndChain.arbitrum({CfAssets asset = CfAssets.eth}) {
    return AssetAndChain._(
        asset: CfChain.arbitrum.validateChainAsset(asset),
        chain: CfChain.arbitrum);
  }

  factory AssetAndChain.fromJson(Map<String, dynamic> json) {
    final chain = CfChain.fromName(json["chain"]);
    return AssetAndChain._(
        asset: CfAssets.fromName(json["asset"]), chain: chain);
  }

  Map<String, dynamic> toJson() {
    return {"asset": asset.name, "chain": chain.name};
  }

  @override
  String toString() {
    return "AssetAndChain{${toJson()}}";
  }

  String getVariant() {
    return chain.getAssetVariant(asset);
  }
}

abstract class AssetAndChainAddress<NETWORKADDRESS> {
  final AssetAndChain chain;
  final NETWORKADDRESS address;
  const AssetAndChainAddress({required this.chain, required this.address});
  String get addressStr => address.toString();
  List<int> decodeToVariantBytes(CfNetwork network) {
    return CfApiUtils.decodeAddress(
        chain: chain.chain, address: address, network: network);
  }

  List<int> addressBytes({CfNetwork? network});
}

class SolanaChainAddress extends AssetAndChainAddress<SolAddress> {
  SolanaChainAddress(SolAddress address, {CfAssets asset = CfAssets.sol})
      : super(address: address, chain: AssetAndChain.solana(asset: asset));

  @override
  List<int> addressBytes({CfNetwork? network}) {
    return address.toBytes();
  }
}

class EthereumChainAddress extends AssetAndChainAddress<ETHAddress> {
  EthereumChainAddress(ETHAddress address, {CfAssets asset = CfAssets.eth})
      : super(address: address, chain: AssetAndChain.ethereum(asset: asset));
  @override
  List<int> addressBytes({CfNetwork? network}) {
    return address.toBytes();
  }
}

class ArbitrumChainAddress extends AssetAndChainAddress<ETHAddress> {
  ArbitrumChainAddress(ETHAddress address, {CfAssets asset = CfAssets.eth})
      : super(address: address, chain: AssetAndChain.arbitrum(asset: asset));
  @override
  List<int> addressBytes({CfNetwork? network}) {
    return address.toBytes();
  }
}

class BitcoinChainAddress extends AssetAndChainAddress<BitcoinAddress> {
  BitcoinChainAddress(BitcoinAddress address)
      : super(address: address, chain: AssetAndChain.bitcoin());

  @override
  String get addressStr => address.address;
  @override
  List<int> addressBytes({CfNetwork? network}) {
    return CfApiUtils.decodeBitcoinAddress(
        address: address, network: network?.bitcoinNetwork ?? address.network);
  }
}

class SubstrateChainAddress extends AssetAndChainAddress<SubstrateAddress> {
  SubstrateChainAddress(SubstrateAddress address)
      : super(address: address, chain: AssetAndChain.polkadot());
  @override
  List<int> addressBytes({CfNetwork? network}) {
    return address.toBytes();
  }
}
