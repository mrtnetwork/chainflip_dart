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
              addedAmount: CfHelper.priceToBig("50", 18)),
          account: address);
  ethereumApi.signTransaction(
      transaction: increateAllowanceTransaction, signer: ethPrivateKey);

  /// https://sepolia.etherscan.io/tx/0x18926e2442d5d2d8dde086cb06052574a3973da688564e597436f58e9a6ae496
  await ethereumApi.sendAndSubmitTransaction(increateAllowanceTransaction);

  final liquidityPrivateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.bip32.childKey(Bip32KeyIndex(2)).privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.secp256k1);
  final liquiditySubstrateAddress = liquidityPrivateKey.toAddress(
      ss58Format: CfHelper.perseveranceSubstrateSS58Format);
  final foundStateChainTransaction =
      await cfEthereumApi.buildStateChainGatewayContractTransaction(
          operation: EvmStateChainGatewayFundStateChainAccountOperation(
              nodeId: liquiditySubstrateAddress,
              amount: CfHelper.priceToBig("50", 18)),
          account: address);
  ethereumApi.signTransaction(
      transaction: foundStateChainTransaction, signer: ethPrivateKey);

  /// https://sepolia.etherscan.io/tx/0xba834221a4603255dad9cf4748d4a3607c85c09855f74c27203e6786c64adb20
  await ethereumApi.sendAndSubmitTransaction(foundStateChainTransaction);

  await Future.delayed(const Duration(minutes: 2));
  final provider =
      SubstrateRPC(SubstrateHttpService(CfNetwork.perseverance.rpcUrl));
  final substrateApi = await SubstrateIntractApi.atRuntimeMetadata(provider);
  final cfSubstrateApi =
      CfSubstrateApi(substrateApi: substrateApi, network: cfNetwork);
  final brokerAccountRouleTransaction =
      await cfSubstrateApi.buildOperationPayload(
          operation: CfSubstrateRegisterLiquidityAccountOperation(),
          source: liquiditySubstrateAddress);
  final extrinsic = substrateApi.signTransaction(
      payload: brokerAccountRouleTransaction, signer: liquidityPrivateKey);

  /// https://scan.perseverance.chainflip.io/extrinsics/3010616-361
  await substrateApi.submitExtrinsicAndWatch(extrinsic: extrinsic);
}
