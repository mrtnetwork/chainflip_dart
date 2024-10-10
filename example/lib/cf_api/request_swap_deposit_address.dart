import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/metadata/metadata.dart';

import 'package:example/services/substrate_service_example.dart';

void main() async {
  final provider =
      SubstrateRPC(SubstrateHttpService(CfNetwork.perseverance.rpcUrl));
  final requestMetadata =
      VersionedMetadata.fromBytes(BytesUtils.fromHexString(chainflipMetaData));
  final metadata = requestMetadata.metadata as MetadataV14;
  final acc = Bip44.fromSeed(List<int>.filled(32, 12), Bip44Coins.cosmos);
  final privateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: acc.privateKey.raw, algorithm: SubstrateKeyAlgorithm.secp256k1);
  final api = CfSubstrateApi(
      substrateApi:
          SubstrateIntractApi(api: MetadataApi(metadata), provider: provider),
      network: CfNetwork.perseverance);
  final result = await api.requestSwapDepositAddress(
      operation: CfSubstrateRequestSwapDepositAddress(
          source: AssetAndChain.solana(),
          destination: ArbitrumChainAddress(
              ETHAddress("0xb0fD77686C9Bb99A3194EDD22F06BBB603F72efE")),
          brokerCommission: 0,
          boostFee: 0),
      source: privateKey.toAddress(ss58Format: 2112),
      signer: privateKey);
  print(result.address);
}
