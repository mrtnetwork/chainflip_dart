import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestEnvironment
    extends CfRPCRequestParam<Environment, Map<String, dynamic>> {
  @override
  String get method => "cf_environment";

  @override
  Environment onResonse(Map<String, dynamic> result) {
    return Environment.fromJson(result);
  }
}
