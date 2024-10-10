import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/cf_service.dart';

void main() async {
  const cfNetwork = CfNetwork.mainnet;
  final provider = CfProvider(
      CfHttpProvider(url: cfNetwork.rpcUrl, backendUrl: cfNetwork.backendUrl));
  await provider.request(CfRPCRequestAccounts());
  await provider.request(CfRPCRequestSwapRateV2(
      fromAsset: const UncheckedAssetAndChain(asset: "ETH", chain: "Ethereum"),
      amount: BigInt.parse("111111111111111111"),
      toAsset: const UncheckedAssetAndChain(asset: "BTC", chain: "Bitcoin")));

  await provider.request(const CfBackendRequestSwapStatusV2("51742"));
  await provider.request(CfBackendRequestQuoteV2(
      amount: ETHHelper.toWei("1").toString(),
      destAsset: CfAssets.btc.name,
      destChain: CfChain.bitcoin.name,
      srcAsset: CfAssets.eth.name,
      srcChain: CfChain.ethereum.name,
      brokerCommissionBps: 10));
  // print(env.toJson());
}
