import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestBoostPoolDetails
    extends CfRPCRequestParam<List<BoostPoolDetailsResponse>, List> {
  final UncheckedAssetAndChain? asset;
  const CfRPCRequestBoostPoolDetails({this.asset});
  @override
  List get params => [asset?.toJson()];
  @override
  String get method => "cf_boost_pool_details";

  @override
  List<BoostPoolDetailsResponse> onResonse(List result) {
    return result.map((e) => BoostPoolDetailsResponse.fromJson(e)).toList();
  }
}
