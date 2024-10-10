import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/solana_service_example.dart';

void main() async {
  final provider =
      SolanaRPC(SolanaHttpService("https://api.devnet.solana.com"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
  final privateKey = SolanaPrivateKey.fromSeed(hdWallet.privateKey.raw);
  final address = privateKey.publicKey().toAddress();
  final solanaApi = SolanaIntractApi(provider);
  final destination =
      SolAddress("2dH3ygKmh4vuorwC5eN5tNbBDxHNVXbRyN1yuMjKYuGx");
  final instructions = await solanaApi.buildTransferToken(
      destination: destination,
      mintAddress: SolAddress(CfNetwork.perseverance.solUsdcContractAddress),
      owner: address,
      tokenAmount: CfHelper.usdcToBig("0.001"));
  final transaction = await solanaApi.buildTransaction(
      instructions: instructions,
      params: SolanaTransactionParams.v0(payer: address));
  solanaApi.signTransaction(transaction: transaction, signers: [privateKey]);
  await solanaApi.submitTransaction(transaction: transaction);

  // https://explorer.solana.com/tx/5MnQd8FS8uzNkD8fje5wULCBFvkbRjvUmqCJaj7wYaTNv8ZeqSuvKjfMM584rN3CTTM46Lw3ZeRJMqLKgAB6iAqi?cluster=devnet
}
