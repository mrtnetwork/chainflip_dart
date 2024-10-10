import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestBoostPoolsDepth
    extends CfRPCRequestParam<List<BoostPoolDepthResponse>, List> {
  @override
  String get method => "cf_boost_pools_depth";
  @override
  List<BoostPoolDepthResponse> onResonse(List result) {
    print("result $result");
    return result.map((e) => BoostPoolDepthResponse.fromJson(e)).toList();
  }
}
