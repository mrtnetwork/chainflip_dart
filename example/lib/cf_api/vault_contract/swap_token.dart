import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';

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
              spender: ETHAddress(cfNetwork.vaultContractAddress),
              addedAmount: CfHelper.priceToBig("10", 18)),
          account: address);
  ethereumApi.signTransaction(
      transaction: increateAllowanceTransaction, signer: ethPrivateKey);
  await ethereumApi.sendAndSubmitTransaction(increateAllowanceTransaction);

  final swapTransaction = await cfEthereumApi.buildVaultContractTransaction(
      operation: EvmVaultXSwapTokenOperation(
          destination: SolanaChainAddress(
              SolAddress("2dH3ygKmh4vuorwC5eN5tNbBDxHNVXbRyN1yuMjKYuGx")),
          tokenAddress: ETHAddress(cfNetwork.flipContractAddress),
          amount: CfHelper.priceToBig("10", 18),
          cfParameters: const []),
      account: address,
      vaultChain: VaultContractChain.eth);
  ethereumApi.signTransaction(
      transaction: swapTransaction, signer: ethPrivateKey);

  await ethereumApi.sendAndSubmitTransaction(swapTransaction);

  /// https://sepolia.etherscan.io/tx/0x7db1087bd233cb1a38949a6e84e510a04c90191bf111bbb94f25abd7629d2eb9
}
