import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestSwappingEnvironment
    extends CfRPCRequestParam<SwappingEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_swapping_environment";

  @override
  SwappingEnvironment onResonse(Map<String, dynamic> result) {
    print("Result $result");
    return SwappingEnvironment.fromJson(result);
  }
}
