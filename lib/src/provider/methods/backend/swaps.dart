import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/core/swap.dart';
import 'package:chainflip_dart/src/provider/models/models/backend.dart';

class CfBackendRequestSwapStatus
    extends CfRequestParam<VaultSwapResponse2, Map<String, dynamic>> {
  final String id;
  const CfBackendRequestSwapStatus(this.id);
  @override
  Map<String, String?>? get queryParameters => {};

  @override
  String get method => CfSwapMethods.swap.url;

  @override
  List<String> get pathParameters => [id];

  @override
  VaultSwapResponse2 onResonse(Map<String, dynamic> result) {
    // print("result $result");
    return VaultSwapResponse2.fromJson(result);
  }
}
