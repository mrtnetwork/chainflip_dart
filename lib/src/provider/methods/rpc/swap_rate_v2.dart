import 'package:blockchain_utils/helper/helper.dart';
import 'package:chainflip_dart/src/helper/extensions.dart';
import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestSwapRateV2
    extends CfRPCRequestParam<SwapRateV2Response, Map<String, dynamic>> {
  final UncheckedAssetAndChain fromAsset;
  final UncheckedAssetAndChain toAsset;
  final BigInt amount;
  final List<LimitOrder>? additionalOrders;
  CfRPCRequestSwapRateV2(
      {required this.fromAsset,
      required this.toAsset,
      required this.amount,
      List<LimitOrder>? additionalOrders})
      : additionalOrders = additionalOrders?.immutable;

  @override
  List get params => [
        fromAsset.toJson(),
        toAsset.toJson(),
        amount.toHexDecimal,
        additionalOrders?.map((e) => {"LimitOrder": e.toJson()}).toList()
      ];

  @override
  String get method => "cf_swap_rate_v2";

  @override
  SwapRateV2Response onResonse(Map<String, dynamic> result) {
    return SwapRateV2Response.fromJson(result);
  }
}
