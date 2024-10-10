import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';

void main() async {
  final provier =
      EVMRPC(EthereumHttpService("https://rpc-amoy.polygon.technology/"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
  final ethPrivateKey = ETHPrivateKey.fromBytes(hdWallet.privateKey.raw);
  final api = EthereumIntractApi(provier);
  final transaction = await api.buildEthereumTransaction(
      from: ethPrivateKey.publicKey().toAddress(),
      to: ETHAddress("0xDdEDf30f96E6e2674Fab476bfC36201074081bcC"),
      nativeAmount: ETHHelper.toWei("0.2"));
  api.signTransaction(transaction: transaction, signer: ethPrivateKey);
  await transaction.sendTransaction(provier);

  /// https://www.oklink.com/amoy/tx/0xe6eadb6fe31ea804c16ef49c3bddfc2fb55a9d0011c83f3cabb0afcc09607573
}
