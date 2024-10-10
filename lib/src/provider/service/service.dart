import 'package:chainflip_dart/src/provider/core/core.dart';
class ChainFlipRequestResponse{
  final int statusCode;
  final String? response;
  const ChainFlipRequestResponse({required this.statusCode,required this.response});

  bool get isSuccess => statusCode>=200 && statusCode<300;
}

mixin CfServiceProvider {
  String get url;

  Future<ChainFlipRequestResponse> post(CfRequestDetails params, [Duration? timeout]);

  Future<ChainFlipRequestResponse> get(CfRequestDetails params, [Duration? timeout]);
}
