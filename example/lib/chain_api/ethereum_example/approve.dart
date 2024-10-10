import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';

void main() async {
  final provier =
      EVMRPC(EthereumHttpService("https://rpc-amoy.polygon.technology/"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
  final ethPrivateKey = ETHPrivateKey.fromBytes(hdWallet.privateKey.raw);

  final address = ethPrivateKey.publicKey().toAddress();
  final api = EthereumIntractApi(provier);
  final transaction = await api.buildErc20ContractOperation(
      account: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmApproveOperation(
          addedAmount: CfHelper.priceToBig("1", 18),
          spender: ETHAddress("0xDdEDf30f96E6e2674Fab476bfC36201074081bcC")));

  api.signTransaction(transaction: transaction, signer: ethPrivateKey);
  await transaction.sendTransaction(provier);
}

/// https://www.oklink.com/amoy/tx/0x0f2799c4f38aa05f7a55e2bda61411711dea00571bdf637c59f02c4f879cd31f
