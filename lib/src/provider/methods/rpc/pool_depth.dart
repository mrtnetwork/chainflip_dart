import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';
import 'package:chainflip_dart/src/types/types/asset_and_chain.dart';

class CfRPCRequestPoolDepth
    extends CfRPCRequestParam<PoolDepth?, Map<String, dynamic>?> {
  final AssetAndChain fromAsset;
  final AssetAndChain toAsset;
  final TickRangeParams tickRange;
  const CfRPCRequestPoolDepth(
      {required this.fromAsset,
      required this.toAsset,
      required this.tickRange});

  @override
  List get params => [fromAsset.toJson(), toAsset.toJson(), tickRange.toJson()];

  @override
  String get method => "cf_pool_depth";

  @override
  PoolDepth? onResonse(Map<String, dynamic>? result) {
    if (result == null) return null;
    return PoolDepth.fromJson(result);
  }
}
