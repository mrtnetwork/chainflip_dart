import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/substrate_service_example.dart';

void main() async {
  final provider =
      SubstrateRPC(SubstrateHttpService("https://westend-rpc.polkadot.io"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.polkadotTestnetEd25519Slip);
  final privateKey = SubstratePrivateKey.fromPrivateKey(
      keyBytes: hdWallet.privateKey.raw,
      algorithm: SubstrateKeyAlgorithm.ed25519);
  final address = privateKey.toAddress();
  final metadata = await provider.request(const SubstrateRPCStateGetMetadata());
  final api = SubstrateIntractApi(api: metadata.toApi(), provider: provider);
  final destination =
      SubstrateAddress("5E3LJpRKRa9k66VguA2LEgieAtzu7kFyC7yjYBybkhQAYy4h");

  final transaferBytes = api.builTransferCallBytes(
      destination: destination, amount: SubstrateHelper.toKSM("0.1"));
  final transaction =
      await api.buildTransaction(callBytes: transaferBytes, source: address);
  final extrinsic =
      api.signTransaction(payload: transaction, signer: privateKey);
  await api.submitExtrinsicAndWatch(extrinsic: extrinsic);
}

/// https://westend.subscan.io/extrinsic/0x06cc98fbf683a59bc00e090d2d3e6abf425bbd3b9a74fcb0dc605a3c6d496704
