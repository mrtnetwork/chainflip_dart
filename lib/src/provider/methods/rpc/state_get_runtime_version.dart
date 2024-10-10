import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestStateGetRuntimeVersion
    extends CfRPCRequestParam<RuntimeVersionResponse, Map<String, dynamic>> {
  @override
  String get method => "state_getRuntimeVersion";

  @override
  RuntimeVersionResponse onResonse(Map<String, dynamic> result) {
    return RuntimeVersionResponse.fromJson(result);
  }
}
