import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';
import 'package:example/services/substrate_service_example.dart';

void main() async {
  const cfNetwork = CfNetwork.perseverance;
  final ethereumProvier = EVMRPC(
      EthereumHttpService("https://ethereum-sepolia-rpc.publicnode.com"));
  final ethereumApi = EthereumIntractApi(ethereumProvier);
  final cfEthereumApi = CfEvmApi(network: cfNetwork, ethereumApi: ethereumApi);
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum).deriveDefaultPath;
  final ethPrivateKey = ETHPrivateKey.fromBytes(hdWallet.privateKey.raw);
  final address = ethPrivateKey.publicKey().toAddress();
  final increateAllowanceTransaction =
      await cfEthereumApi.buildFlipContractTransaction(
          operation: EvmIncreaseAllowanceOperation(
              spender: ETHAddress(cfNetwork.stateChainGatewayAddress),
              addedAmount: CfHelper.priceToBig("100", 18)),
          account: address);
  ethereumApi.signTransaction(
      transaction: increateAllowanceTransaction, signer: ethPrivateKey);

  await ethereumApi.sendAndSubmitTransaction(increateAllowanceTransaction);

  final brokerPrivateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.bip32.childKey(Bip32KeyIndex(1)).privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.secp256k1);
  final brokerSubstrateAddress = brokerPrivateKey.toAddress(
      ss58Format: CfHelper.perseveranceSubstrateSS58Format);
  final foundStateChainTransaction =
      await cfEthereumApi.buildStateChainGatewayContractTransaction(
          operation: EvmStateChainGatewayFundStateChainAccountOperation(
              nodeId: brokerSubstrateAddress,
              amount: CfHelper.priceToBig("10", 18)),
          account: address);
  ethereumApi.signTransaction(
      transaction: foundStateChainTransaction, signer: ethPrivateKey);
  await ethereumApi.sendAndSubmitTransaction(foundStateChainTransaction);

  await Future.delayed(const Duration(minutes: 1));
  final provider =
      SubstrateRPC(SubstrateHttpService(CfNetwork.perseverance.rpcUrl));
  final substrateApi = await SubstrateIntractApi.atRuntimeMetadata(provider);
  final cfSubstrateApi =
      CfSubstrateApi(substrateApi: substrateApi, network: cfNetwork);
  final brokerAccountRouleTransaction =
      await cfSubstrateApi.buildOperationPayload(
          operation: CfSubstrateRegisterBrokerOperation(),
          source: brokerSubstrateAddress);
  final extrinsic = substrateApi.signTransaction(
      payload: brokerAccountRouleTransaction, signer: brokerPrivateKey);
  await substrateApi.submitExtrinsicAndWatch(extrinsic: extrinsic);

  /// https://scan.perseverance.chainflip.io/extrinsics/3010483-241
}
