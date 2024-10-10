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
  final swapNativeTransaction = await cfEthereumApi.buildVaultContractTransaction(
      operation: EvmVaultXSwapNativeOperation(
          destination: BitcoinChainAddress(BitcoinAddress(
              "tb1p53tzgvqwunxjr05l3hesh0lgjp7evhpgawqhc3uty77h5q68wk3sua6pcl",
              network: BitcoinNetwork.testnet)),
          cfParameters: const []),
      account: address,
      vaultChain: VaultContractChain.eth,
      nativeAmount: CfHelper.priceToBig("0.001", 18));
  ethereumApi.signTransaction(
      transaction: swapNativeTransaction, signer: ethPrivateKey);
  await ethereumApi.sendAndSubmitTransaction(swapNativeTransaction);

  /// https://sepolia.etherscan.io/tx/0x52816372d6eee51d3a6f64fc4bc4606b880a8841d6a4a8ce5361fd8be11f8534
  /// https://scan.perseverance.chainflip.io/swaps/3688
}
