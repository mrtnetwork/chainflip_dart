import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/core/swap.dart';
import 'package:chainflip_dart/src/provider/models/models/backend.dart';

class CfBackendRequestQuoteV2
    extends CfRequestParam<List<QuoteQueryResponse>, List> {
  CfBackendRequestQuoteV2(
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
  Map<String, dynamic>? get queryParameters => {
        "amount": amount,
        "srcChain": srcChain,
        "srcAsset": srcAsset,
        "destChain": destChain,
        "destAsset": destAsset,
        "brokerCommissionBps": brokerCommissionBps?.toString(),
        "dcaEnabled": 'false',
        "affiliateBrokers":
            affiliateBrokers?.map((e) => e.toJson()).toList().toString()
      };

  @override
  String get method => CfSwapMethods.quoteV2.url;

  @override
  List<String> get pathParameters => [];
  @override
  List<QuoteQueryResponse> onResonse(List result) {
    return result.map((e) => QuoteQueryResponse.fromJson(e)).toList();
  }
}
