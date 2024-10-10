import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestPoolPricev2
    extends CfRPCRequestParam<PoolPriceV2Response, Map<String, dynamic>> {
  final UncheckedAssetAndChain baseAsset;
  final UncheckedAssetAndChain quoteAsset;
  const CfRPCRequestPoolPricev2(
      {required this.baseAsset, required this.quoteAsset});

  @override
  List get params => [baseAsset.toJson(), quoteAsset.toJson()];

  @override
  String get method => "cf_pool_price_v2";

  @override
  PoolPriceV2Response onResonse(Map<String, dynamic> result) {
    return PoolPriceV2Response.fromJson(result);
  }
}
