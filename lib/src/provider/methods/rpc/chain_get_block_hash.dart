import 'package:chainflip_dart/src/provider/core/core.dart';

class CfRPCRequestChainGetBlockHash extends CfRPCRequestParam<String, String> {
  final int? blockHeight;
  const CfRPCRequestChainGetBlockHash({this.blockHeight});
  @override
  String get method => "chain_getBlockHash";
  @override
  List get params => [blockHeight];
}
