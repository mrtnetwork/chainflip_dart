import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/api/cf/utils/utils.dart';
import 'package:chainflip_dart/src/types/types/asset_and_chain.dart';
import 'package:chainflip_dart/src/types/types/chain_flip_networks.dart';
import 'package:chainflip_dart/src/types/types/chain_type.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _SubstrateOperationConst {
  static const String swappingPallet = "Swapping";
  static const String liquidityProvider = "LiquidityProvider";
}

/// Abstract class for chain flip substrate operation serialization.
abstract class CfSubstrateOperationSerialization {
  Map<String, dynamic> template(CfNetwork network);
}

/// Abstract class for chain flip substrate operation
abstract class CfSubstrateOperation
    implements CfSubstrateOperationSerialization {
  const CfSubstrateOperation();

  /// abi metadata pallet name
  String get pallet;
  List<int> serializeCall(
      {required LatestMetadataInterface metadata, required CfNetwork network}) {
    final lockupId = metadata.getCallLookupId(pallet);
    final encode = [
      metadata.getPalletIndex(pallet),
      ...metadata.encodeLookup(
          id: lockupId, value: template(network), fromTemplate: true)
    ];
    return encode;
  }
}

/// Registers a new broker; note the account must be in an unregistered position.
class CfSubstrateRegisterBrokerOperation extends CfSubstrateOperation {
  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "type": "Enum",
      "key": "register_as_broker",
      "value": null,
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.swappingPallet;
}

/// Deregisters broker account; account must clean up assets and withdraw first.
class CfDeregisterBrokerOperation extends CfSubstrateOperation {
  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "type": "Enum",
      "key": "deregister_as_broker",
      "value": null,
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.swappingPallet;
}

/// Opens a new swapping channel; account must be in broker position.
class CfSubstrateRequestSwapDepositAddress<T extends AssetAndChainAddress>
    extends CfSubstrateOperation {
  /// source asset and chain
  final AssetAndChain source;

  /// destination asset, chain and address
  final T destination;

  /// broker commission
  final int brokerCommission;
  final CfRefundParameters<T>? refundParameters;
  final CfDCAParameters? dcaParameters;
  final List<CfAffiliateFeesParams> affiliateFees;
  final CfChannelMetadataParams? channelMetadata;

  /// boost fee
  final int boostFee;
  const CfSubstrateRequestSwapDepositAddress(
      {required this.source,
      required this.destination,
      required this.brokerCommission,
      required this.boostFee,
      this.refundParameters,
      this.dcaParameters,
      this.affiliateFees = const [],
      this.channelMetadata});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "request_swap_deposit_address_with_affiliates",
      "value": {
        "value": {
          "source_asset": {
            "key": source.getVariant(),
            "value": null,
          },
          "destination_asset": {
            "key": destination.chain.getVariant(),
            "value": null,
          },
          "destination_address": {
            "key": destination.chain.chain.getChainVariant(),
            "value": {"value": destination.decodeToVariantBytes(network)},
          },
          "broker_commission": {"value": brokerCommission},
          "channel_metadata": {"value": channelMetadata?.template(network)},
          "boost_fee": {"value": boostFee},
          "affiliate_fees": {
            "value": affiliateFees
                .map((e) => {"value": e.template(network)})
                .toList()
          },
          "refund_parameters": {"value": refundParameters?.template(network)},
          "dca_parameters": {"value": dcaParameters?.template(network)}
        }
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.swappingPallet;
}

class CfChannelMetadataParams implements CfSubstrateOperationSerialization {
  final List<int> message;
  final BigInt gasBudget;
  final List<int> cfParameters;
  CfChannelMetadataParams(
      {required List<int> message,
      required this.gasBudget,
      required List<int> cfParameters})
      : message = message.asImmutableBytes,
        cfParameters = cfParameters.asImmutableBytes;

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "message": {"value": message},
      "gas_budget": {"value": gasBudget},
      "cf_parameters": {"value": cfParameters}
    };
  }
}

class CfAffiliateFeesParams implements CfSubstrateOperationSerialization {
  final SubstrateAddress address;
  final int bps;
  const CfAffiliateFeesParams({required this.address, required this.bps});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "account": {"value": address.toBytes()},
      "bps": {"value": bps}
    };
  }
}

class CfRefundParameters<T extends AssetAndChainAddress>
    implements CfSubstrateOperationSerialization {
  final List<BigInt> minPrice;
  final T refundAddress;
  final int retryDuration;
  CfRefundParameters({
    List<BigInt> minPrice = const [],
    required this.refundAddress,
    required int retryDuration,
  })  : minPrice = minPrice.map((e) => e.asUint64).toList(),
        retryDuration = retryDuration.asUint32;

  Map<String, dynamic> _addressTemplate(CfNetwork network) {
    switch (refundAddress.chain.chain) {
      case CfChain.solana:
      case CfChain.arbitrum:
      case CfChain.ethereum:
      case CfChain.polkadot:
        return {"value": refundAddress.decodeToVariantBytes(network)};
      case CfChain.bitcoin:
        return {
          "value": {
            "Btc": {
              "type": "Enum",
              "key": CfApiUtils.getBitcoinAddressVariant(refundAddress),
              "value": {
                "value": CfApiUtils.decodeBitcoinProgramAddress(refundAddress)
              },
            }
          }
        };
      default:
        throw DartCfPluginException("Invalid refund addresss");
    }
  }

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "retry_duration": {"type": "U32", "value": retryDuration},
      "refund_address": {
        "type": "Enum",
        "key": refundAddress.chain.chain.getChainVariant(),
        "value": _addressTemplate(network),
      },
      "min_price": {"value": minPrice}
    };
  }
}

class CfDCAParameters implements CfSubstrateOperationSerialization {
  final int numberOfChunks;
  final int chunkInterval;
  CfDCAParameters({required int numberOfChunks, required int chunkInterval})
      : numberOfChunks = numberOfChunks.asUint32,
        chunkInterval = chunkInterval.asUint32;

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "number_of_chunks": {"value": numberOfChunks},
      "chunk_interval": {"value": chunkInterval}
    };
  }
}

/// withraw asset from boker account.
class CfSubstrateBrokerWithdrawOperation<T extends AssetAndChainAddress>
    extends CfSubstrateOperation {
  /// chain, asset and related chain address for withdraw
  final T address;
  const CfSubstrateBrokerWithdrawOperation(this.address);

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "withdraw",
      "value": {
        "value": {
          "asset": {
            "key": address.chain.getVariant(),
            "value": null,
          },
          "destination_address": {
            "key": address.chain.chain.getChainVariant(),
            "value": {"value": address.decodeToVariantBytes(network)},
          }
        }
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.swappingPallet;
}

/// Registers a Liquidity Account; account must be in unregistered position.
class CfSubstrateRegisterLiquidityAccountOperation
    extends CfSubstrateOperation {
  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "type": "Enum",
      "key": "register_lp_account",
      "value": null,
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}

/// Deregister a Liquidity Account;
class CfSubstrateDeregisterLiquidityAccountOperation
    extends CfSubstrateOperation {
  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "type": "Enum",
      "key": "deregister_lp_account",
      "value": null,
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}

/// Opens a liquidity deposit channel. First use `CfSubstrateRegisterLiquidityRefundAddressOperation`
/// to set the refund address for the deposit asset, otherwise it will fail.
class CfSubstrateLiquidityDepositAddressOperation extends CfSubstrateOperation {
  final AssetAndChain asset;
  final int boostFee;

  const CfSubstrateLiquidityDepositAddressOperation(
      {required this.asset, required this.boostFee});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "request_liquidity_deposit_address",
      "value": {
        "value": {
          "asset": {"type": "Enum", "key": asset.getVariant(), "value": null},
          "boost_fee": {"value": boostFee}
        }
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}

/// Sets the refund address for the current asset.
class CfSubstrateRegisterLiquidityRefundAddressOperation<NETWORKADDRESS>
    extends CfSubstrateOperation {
  final CfChain chain;
  final NETWORKADDRESS refundAddress;

  const CfSubstrateRegisterLiquidityRefundAddressOperation(
      {required this.chain, required this.refundAddress});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "register_liquidity_refund_address",
      "value": {
        "key": chain.getChainVariant(),
        "value": {
          "value": CfApiUtils.decodeAddress(
              chain: chain, address: refundAddress, network: network)
        },
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}

/// withdraw asset from liquidity account
class CfSubstrateLiquidityWithdrawAssetOperation<T extends AssetAndChainAddress>
    extends CfSubstrateOperation {
  /// address, chain and destination asset
  final T address;

  /// amount to withdraw
  final BigInt amount;
  const CfSubstrateLiquidityWithdrawAssetOperation(
      {required this.address, required this.amount});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "withdraw_asset",
      "value": {
        "value": {
          "amount": {"value": amount},
          "asset": {"key": address.chain.getVariant()},
          "destination_address": {
            "key": address.chain.chain.getChainVariant(),
            "value": {"value": address.decodeToVariantBytes(network)},
          }
        }
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}

/// transfer asset from liquidity account to other substrate account
class CfSubstrateLiquidityTransferAssetOperation extends CfSubstrateOperation {
  /// asset to transfer
  final AssetAndChain asset;

  /// destionation
  final SubstrateAddress address;

  /// amount of asset
  final BigInt amount;
  const CfSubstrateLiquidityTransferAssetOperation(
      {required this.asset, required this.address, required this.amount});

  @override
  Map<String, dynamic> template(CfNetwork network) {
    return {
      "key": "transfer_asset",
      "value": {
        "value": {
          "amount": {"value": amount},
          "asset": {"key": asset.getVariant(), "value": null},
          "destination": {"value": address.toBytes()}
        }
      }
    };
  }

  @override
  String get pallet => _SubstrateOperationConst.liquidityProvider;
}
