import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/core/swap.dart';
import 'package:chainflip_dart/src/provider/models/models/backend.dart';

class CfBackendRequestQuote
    extends CfRequestParam<QuoteQueryResponse, Map<String, dynamic>> {
  CfBackendRequestQuote(
      {required this.srcChain,
      required this.srcAsset,
      required this.destChain,
      required this.destAsset,
      required this.amount,
      this.brokerCommissionBps,
      List<AffiliateBroker>? affiliateBrokers})
      : affiliateBrokers = affiliateBrokers?.immutable;
  final String srcChain;
  final String srcAsset;
  final String destChain;
  final String destAsset;
  final String amount;
  final int? brokerCommissionBps;
  final List<AffiliateBroker>? affiliateBrokers;
  @override
  Map<String, String?>? get queryParameters => {
        "amount": amount,
        "srcChain": srcChain,
        "srcAsset": srcAsset,
        "destChain": destChain,
        "destAsset": destAsset,
        "brokerCommissionBps": brokerCommissionBps?.toString(),
        "dcaEnabled": 'false',
        "affiliateBrokers": [].toString()
      };

  @override
  String get method => CfSwapMethods.quote.url;

  @override
  List<String> get pathParameters => [];
  @override
  QuoteQueryResponse onResonse(Map<String, dynamic> result) {
    return QuoteQueryResponse.fromJson(result);
  }
}
