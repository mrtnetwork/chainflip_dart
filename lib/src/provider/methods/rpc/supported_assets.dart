import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/types/types/asset_and_chain.dart';

class CfRPCRequestSupportAssets extends CfRPCRequestParam<
    List<AssetAndChain>, List<Map<String, dynamic>>> {
  @override
  String get method => "cf_supported_assets";

  @override
  List<AssetAndChain> onResonse(List<Map<String, dynamic>> result) {
    return result.map((e) => AssetAndChain.fromJson(e)).toList();
  }
}
