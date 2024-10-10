import 'dart:async';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/provider/models/models/rpc.dart';
import 'package:chainflip_dart/src/api/cf/utils/utils.dart';
import 'package:chainflip_dart/src/api/chains/chains/substrate.dart';
import 'package:chainflip_dart/src/types/types/chain_flip_networks.dart';
import 'package:chainflip_dart/src/api/cf/core/core.dart';
import 'package:chainflip_dart/src/api/cf/operations/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _ChainFlipApiConst {
  static const String depositAddressReadyMethodName = "SwapDepositAddressReady";
  static const String liquidityDepositAddressReadyMethodName =
      "LiquidityDepositAddressReady";
}

/// Mixin for implementing Substrate API interactions in ChainFlip.
mixin SubstrateApiImpl on CfSubstrateApiCore {
  /// Gets the Substrate interaction API.
  SubstrateIntractApi get substrateApi;

  /// Gets the network for the ChainFlip API.
  CfNetwork get network;

  /// Builds the transaction payload for a ChainFlip Substrate operation.
  Future<BaseTransactionPayload> buildOperationPayload({
    required CfSubstrateOperation operation,
    required SubstrateAddress source,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  }) async {
    return substrateApi.buildTransaction(
      callBytes: operation.serializeCall(
        metadata: substrateApi.api.metadata,
        network: network,
      ),
      source: source,
    );
  }

  /// Requests a swap deposit address through the broker, signing and submitting the extrinsic.
  Future<BrokerRequestSwapDepositAddressResponse> requestSwapDepositAddress({
    required CfSubstrateRequestSwapDepositAddress operation,
    required SubstrateAddress? source,
    required SubstratePrivateKey signer,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  }) async {
    final payload = await buildOperationPayload(
      operation: operation,
      source: source ?? signer.toAddress(),
      blockHash: blockHash,
      genesisHash: genesisHash,
      nonce: nonce,
    );
    final extrinsic =
        substrateApi.signTransaction(payload: payload, signer: signer);
    final submit = await substrateApi.submitExtrinsicAndWatch(
      extrinsic: extrinsic,
    );

    final depositEvents = submit.events.where(
        (e) => e.method == _ChainFlipApiConst.depositAddressReadyMethodName);
    for (final e in depositEvents) {
      final Map<String, dynamic> eventInput = (e.input as Map).cast();
      final depositAddress = CfApiUtils.encodeVariantAddress(
        result: eventInput["deposit_address"],
        network: network,
      );
      final destinationAddress = CfApiUtils.encodeVariantAddress(
        result: eventInput["destination_address"],
        network: network,
      );
      if (destinationAddress.item1 == operation.destination.addressStr &&
          destinationAddress.item2 == operation.destination.chain.chain &&
          depositAddress.item2 == operation.source.chain) {
        return BrokerRequestSwapDepositAddressResponse(
          address: depositAddress.item1,
          issuedBlock: submit.blockNumber,
          channelId: IntUtils.parse(eventInput["channel_id"]),
          sourceChainExpiryBlock:
              BigintUtils.parse(eventInput["source_chain_expiry_block"]),
          channelOpeningFee:
              BigintUtils.parse(eventInput["channel_opening_fee"]),
        );
      }
    }
    throw DartCfPluginException(
      "Unable to detect ${_ChainFlipApiConst.depositAddressReadyMethodName} event.",
    );
  }

  /// Requests a liquidity deposit address through the broker, signing and submitting the extrinsic.
  Future<LiquidityDepositAddressResponse> requestLiquidityDepositAddress({
    required CfSubstrateLiquidityDepositAddressOperation operation,
    required SubstrateAddress? source,
    required SubstratePrivateKey signer,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  }) async {
    final payload = await buildOperationPayload(
      operation: operation,
      source: source ?? signer.toAddress(),
      blockHash: blockHash,
      genesisHash: genesisHash,
      nonce: nonce,
    );
    final extrinsic =
        substrateApi.signTransaction(payload: payload, signer: signer);
    final submit = await substrateApi.submitExtrinsicAndWatch(
      extrinsic: extrinsic,
    );

    final depositEvents = submit.events.firstWhere(
      (e) =>
          e.method == _ChainFlipApiConst.liquidityDepositAddressReadyMethodName,
      orElse: () => throw DartCfPluginException(
          "Unable to detect ${_ChainFlipApiConst.depositAddressReadyMethodName} event."),
    );
    final Map<String, dynamic> eventInput = (depositEvents.input as Map).cast();
    final asset = CfApiUtils.getVariantAssets(eventInput["asset"]);
    final destinationAddress = CfApiUtils.encodeVariantAddress(
      result: eventInput["deposit_address"],
      network: network,
    );
    if (asset.asset == operation.asset.asset) {
      return LiquidityDepositAddressResponse(
        depositAddress: destinationAddress.item1,
        asset: asset.asset,
        channelId: BigintUtils.parse(eventInput["channel_id"]),
        channelOpeningFee: BigintUtils.parse(eventInput["channel_opening_fee"]),
        boostFee: IntUtils.parse(eventInput["boost_fee"]),
        depositChainExpiryBlock:
            BigintUtils.parse(eventInput["deposit_chain_expiry_block"]),
        address: SubstrateAddress.fromBytes(
          (eventInput["account_id"] as List).cast(),
        ),
      );
    }
    throw DartCfPluginException(
      "Unable to detect ${_ChainFlipApiConst.liquidityDepositAddressReadyMethodName} event.",
    );
  }
}
