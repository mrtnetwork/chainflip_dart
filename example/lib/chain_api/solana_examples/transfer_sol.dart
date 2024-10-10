import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/solana_service_example.dart';

/// 9BuJH9MSFjjA5mVjA8WzwuJEWi7UZJYUVXvqQnRkFKbE
void main() async {
  final provider =
      SolanaRPC(SolanaHttpService("https://api.devnet.solana.com"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.solana).deriveDefaultPath;
  final privateKey = SolanaPrivateKey.fromSeed(hdWallet.privateKey.raw);
  final address = privateKey.publicKey().toAddress();
  final solanaApi = SolanaIntractApi(provider);
  final destination =
      SolAddress("9BuJH9MSFjjA5mVjA8WzwuJEWi7UZJYUVXvqQnRkFKbE");
  final transaferInstruction = await solanaApi.buildTransferInstruction(
      lamports: CfHelper.solToLamports("2"),
      source: address,
      destination: destination);
  final transaction = await solanaApi.buildTransaction(
      instructions: [transaferInstruction],
      params: SolanaTransactionParams.v0(payer: address));
  solanaApi.signTransaction(transaction: transaction, signers: [privateKey]);
  await solanaApi.submitTransaction(transaction: transaction);

  /// https://explorer.solana.com/tx/5E2h1fcksXGnnGXFxUgJVGspKB33QfzKmr71iLZYuhN2P6d147PkA82fZVJZ8R9bacHM3g5f3mFq5NaY1MD5aNrK?cluster=devnet
}
