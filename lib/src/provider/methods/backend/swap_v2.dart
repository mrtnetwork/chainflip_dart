import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/core/swap.dart';
import 'package:chainflip_dart/src/provider/models/models/v2.dart';

class CfBackendRequestSwapStatusV2
    extends CfRequestParam<SwapStatusResponseV2, Map<String, dynamic>> {
  final String id;
  const CfBackendRequestSwapStatusV2(this.id);
  @override
  Map<String, String?>? get queryParameters => {};

  @override
  String get method => CfSwapMethods.swapV2.url;

  @override
  List<String> get pathParameters => [id];

  @override
  SwapStatusResponseV2 onResonse(Map<String, dynamic> result) {
    return SwapStatusResponseV2.fromJson(result);
  }
}
