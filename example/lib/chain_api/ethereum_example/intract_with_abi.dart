import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';
import 'simple_abi.dart';

void main() async {
  final provier =
      EVMRPC(EthereumHttpService("https://rpc-amoy.polygon.technology/"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
  final ethPrivateKey = ETHPrivateKey.fromBytes(hdWallet.privateKey.raw);

  final contract = ContractABI.fromJson(erc20Abi);

  final address = ethPrivateKey.publicKey().toAddress();
  final api = EthereumIntractApi(provier);
  final destination = ETHAddress("0xDdEDf30f96E6e2674Fab476bfC36201074081bcC");
  final tokenAmount = CfHelper.priceToBig("1", 18);
  final transaction = await api.buildContractTransaction(
    account: address,
    contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
    function: contract.functionFromName("transfer"),
    functionInputs: [destination, tokenAmount],
  );
  api.signTransaction(transaction: transaction, signer: ethPrivateKey);
  await transaction.sendTransaction(provier);
}

/// https://www.oklink.com/amoy/tx/0xbb02808b6c46a3fa7d2e06f0edcfb0275af8247b22a434028b4f68aa57974dcf
