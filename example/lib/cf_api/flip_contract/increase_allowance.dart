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
  final spender = ETHAddress("0xAf738B15BaAb642E692c672ea7De4f8dd5B2886F");
  final transaction = await cfEthereumApi.buildFlipContractTransaction(
      operation: EvmIncreaseAllowanceOperation(
          spender: spender, addedAmount: CfHelper.priceToBig("100", 18)),
      account: address);
  ethereumApi.signTransaction(transaction: transaction, signer: ethPrivateKey);
  await ethereumApi.sendTransaction(transaction);
}

// https://sepolia.etherscan.io/tx/0x8f5485d773223a455bf9e60208ce2d5ef38aba9b303ef5196a1e57d4e305dfa6
