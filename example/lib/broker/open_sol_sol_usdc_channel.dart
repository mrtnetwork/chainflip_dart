import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/metadata/metadata.dart';
import 'package:example/services/substrate_service_example.dart';

/// https://scan.perseverance.chainflip.io/swaps/3674
void main() async {
  const network = CfNetwork.perseverance;
  final provider =
      SubstrateRPC(SubstrateHttpService(CfNetwork.perseverance.rpcUrl));
  final versionedMetadata =
      VersionedMetadata<MetadataV14>.fromHex(chainflipMetaData);
  final api = CfSubstrateApi(
      substrateApi: SubstrateIntractApi(
          provider: provider, api: versionedMetadata.toApi()),
      network: network);
  final hdWallet = Bip44.fromSeed(List<int>.filled(32, 12), Bip44Coins.cosmos);
  final brokerPrivateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.secp256k1);
  final ownerAccount = brokerPrivateKey.toAddress(
      ss58Format: CfHelper.perseveranceSubstrateSS58Format);
  final destinationAddr =
      SolAddress("BzgYqWVGhvLitJiwT5myjeFe2hvxGna6AZHUvjfWGWLq");
  await api.requestSwapDepositAddress(
      operation: CfSubstrateRequestSwapDepositAddress(
          source: AssetAndChain.solana(),
          destination:
              SolanaChainAddress(destinationAddr, asset: CfAssets.usdc),
          brokerCommission: 0,
          boostFee: 0),
      source: ownerAccount,
      signer: brokerPrivateKey);

  /// https://scan.perseverance.chainflip.io/swaps/3674
}
