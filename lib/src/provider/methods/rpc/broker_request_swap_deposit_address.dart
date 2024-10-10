import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';

class CfRPCRequestBrokerRequestSwapDepositAddress extends CfRPCRequestParam<
    BrokerRequestSwapDepositAddressResponse, Map<String, dynamic>> {
  final UncheckedAssetAndChain sourceAsset;
  final UncheckedAssetAndChain destinationAsset;
  final String destinationAddress;
  final int? brokerCommission;
  final CCMMetadataParams? ccmMetadata;
  final int? boostFee;
  final DCAParams? dcaParams;
  final FillOrKillParams? fillOrKillParams;
  final AffiliateFeesParams? affiliateFees;
  const CfRPCRequestBrokerRequestSwapDepositAddress(
      {required this.sourceAsset,
      required this.destinationAsset,
      required this.destinationAddress,
      required this.brokerCommission,
      this.ccmMetadata,
      this.boostFee,
      this.dcaParams,
      this.fillOrKillParams,
      this.affiliateFees});
  @override
  List get params => [
        sourceAsset,
        destinationAsset,
        destinationAddress,
        brokerCommission,
        ccmMetadata?.toJson(),
        boostFee,
        affiliateFees?.toJson(),
        fillOrKillParams?.toJson(),
        dcaParams?.toJson()
      ];
  @override
  String get method => "broker_requestSwapDepositAddress";

  @override
  BrokerRequestSwapDepositAddressResponse onResonse(
      Map<String, dynamic> result) {
    return BrokerRequestSwapDepositAddressResponse.fromJson(result);
  }
}
