import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/substrate/substrate_websocket.dart';

void main() async {
  final service =
      await SubstrateWebsocketService.connect("wss://paseo.rpc.amforc.com:443");
  final provider = SubstrateRPC(service);
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.polkadotTestnetEd25519Slip);
  final privateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.ed25519);
  final address = privateKey.toAddress(ss58Format: SS58Const.polkadot);
  final metadata = await provider.request(const SubstrateRPCStateGetMetadata());
  final api = SubstrateIntractApi(api: metadata.toApi(), provider: provider);
  final destination =
      SubstrateAddress("14uU4YHm9oqCMEHDWUSDv7tXnS1LQE9mDaqXPHDSZ33QkBkC");
  final transaferBytes = api.builTransferCallBytes(
      destination: destination, amount: SubstrateHelper.toDOT("1"));
  final transaction =
      await api.buildTransaction(callBytes: transaferBytes, source: address);
  final extrinsic =
      api.signTransaction(payload: transaction, signer: privateKey);
  await api.submitExtrinsicAndWatch(extrinsic: extrinsic);
}
