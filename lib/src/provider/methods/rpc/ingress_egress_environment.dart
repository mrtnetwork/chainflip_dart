import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestIngressEgressEnvironment
    extends CfRPCRequestParam<IngressEgressEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_ingress_egress_environment";

  @override
  IngressEgressEnvironment onResonse(Map<String, dynamic> result) {
    return IngressEgressEnvironment.fromJson(result);
  }
}
