import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestFundingEnvironment
    extends CfRPCRequestParam<FundingEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_funding_environment";

  @override
  FundingEnvironment onResonse(Map<String, dynamic> result) {
    return FundingEnvironment.fromJson(result);
  }
}
