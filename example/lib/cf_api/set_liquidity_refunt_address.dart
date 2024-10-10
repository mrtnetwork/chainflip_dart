import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/substrate_service_example.dart';

void main() async {
  const cfNetwork = CfNetwork.perseverance;
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum).deriveDefaultPath;
  final liquidityPrivateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.bip32.childKey(Bip32KeyIndex(2)).privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.secp256k1);
  final liquiditySubstrateAddress = liquidityPrivateKey.toAddress(
      ss58Format: CfHelper.perseveranceSubstrateSS58Format);
  final provider =
      SubstrateRPC(SubstrateHttpService(CfNetwork.perseverance.rpcUrl));
  final substrateApi = await SubstrateIntractApi.atRuntimeMetadata(provider);
  final cfSubstrateApi =
      CfSubstrateApi(substrateApi: substrateApi, network: cfNetwork);

  final setRefundAddressTransaction = await cfSubstrateApi.buildOperationPayload(
      operation: CfSubstrateRegisterLiquidityRefundAddressOperation(
          chain: CfChain.bitcoin,
          refundAddress: BitcoinAddress(
              "tb1p53tzgvqwunxjr05l3hesh0lgjp7evhpgawqhc3uty77h5q68wk3sua6pcl",
              network: BitcoinNetwork.testnet)),
      source: liquiditySubstrateAddress);
  final extrinsic = substrateApi.signTransaction(
      payload: setRefundAddressTransaction, signer: liquidityPrivateKey);

  await substrateApi.submitExtrinsicAndWatch(extrinsic: extrinsic);

  /// https://scan.perseverance.chainflip.io/lps/cFJzdpu7mFA2bMQVJRm6tHXkJsu8PMjDuJJshmfZ3zeav2v5B
}
