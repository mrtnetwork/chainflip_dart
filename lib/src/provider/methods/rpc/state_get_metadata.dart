import 'package:chainflip_dart/src/provider/core/core.dart';

class CfRPCRequestStateGetMetadata
    extends CfRPCRequestParam<String, String> {
  @override
  String get method => "state_getMetadata";
}
