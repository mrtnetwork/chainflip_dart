import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestPoolsEnvironment
    extends CfRPCRequestParam<PoolsEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_pools_environment";

  @override
  PoolsEnvironment onResonse(Map<String, dynamic> result) {
    return PoolsEnvironment.fromJson(result);
  }
}
