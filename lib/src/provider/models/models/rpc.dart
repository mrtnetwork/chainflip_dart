import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/helper/extensions.dart';
import 'package:chainflip_dart/src/types/types/assets.dart';
import 'package:chainflip_dart/src/types/types/chain_type.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class LimitOrderSide {
  final String name;
  const LimitOrderSide._(this.name);
  static const LimitOrderSide buy = LimitOrderSide._("buy");
  static const LimitOrderSide sell = LimitOrderSide._("sell");
  static List<LimitOrderSide> get values => [buy, sell];
}

class LimitOrder {
  final UncheckedAssetAndChain baseAsset;
  final UncheckedAssetAndChain quoteAsset;
  final LimitOrderSide side;
  final int tick;
  final BigInt sellAmount;
  const LimitOrder(
      {required this.baseAsset,
      required this.quoteAsset,
      required this.side,
      required this.tick,
      required this.sellAmount});
  Map<String, dynamic> toJson() {
    return {
      "base_asset": baseAsset.toJson(),
      "quote_asset": quoteAsset.toJson(),
      "side": side.name,
      "sell_amount": sellAmount.toHexDecimal
    };
  }
}

class CCMMetadataParams {
  final String message;
  final String gasBudget;
  const CCMMetadataParams({required this.message, required this.gasBudget});
  Map<String, dynamic> toJson() {
    return {"message": message, "gas_budget": gasBudget};
  }
}

class FillOrKillParams {
  final String refundAddress;
  final int retryDurationBlocks;
  final String minPrice;
  const FillOrKillParams(
      {required this.refundAddress,
      required this.retryDurationBlocks,
      required this.minPrice});
  factory FillOrKillParams.fromJson(Map<String, dynamic> json) {
    return FillOrKillParams(
        refundAddress: json["refundAddress"],
        retryDurationBlocks: json["retryDurationBlocks"],
        minPrice: json["minPrice"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "refund_address": refundAddress,
      "min_price": minPrice,
      "retry_duration_blocks": retryDurationBlocks
    };
  }
}

class DCAParams {
  final int numberOfChunks;
  final int chunkInterval;
  const DCAParams({required this.numberOfChunks, required this.chunkInterval});
  Map<String, dynamic> toJson() {
    return {
      "chunk_interval": chunkInterval,
      "number_of_chunks": numberOfChunks
    };
  }

  factory DCAParams.fromJson(Map<String, dynamic> json) {
    return DCAParams(
        numberOfChunks: json["number_of_chunks"] ?? json["numberOfChunks"],
        chunkInterval: json["chunk_interval"] ?? json["chunkIntervalBlocks"]);
  }
}

class AffiliateFeesParams {
  final String account;
  final int bps;
  const AffiliateFeesParams({required this.account, required this.bps});
  Map<String, dynamic> toJson() {
    return {"account": account, "bps": bps};
  }
}

class TickRangeParams {
  final int start;
  final int end;
  const TickRangeParams({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {"start": start, "end": end};
  }
}

class UncheckedAssetAndChain {
  final String asset;
  final String chain;
  const UncheckedAssetAndChain({required this.asset, required this.chain});
  factory UncheckedAssetAndChain.fromJson(Map<String, dynamic> json) {
    return UncheckedAssetAndChain(asset: json["asset"], chain: json["chain"]);
  }
  Map<String, dynamic> toJson() {
    return {"asset": asset, "chain": chain};
  }
}

class LiquidityDepositAddressResponse {
  final BigInt channelId;
  final CfAssets asset;
  final String depositAddress;
  final BigInt depositChainExpiryBlock;
  final int boostFee;
  final BigInt channelOpeningFee;
  final SubstrateAddress address;
  const LiquidityDepositAddressResponse(
      {required this.channelId,
      required this.depositAddress,
      required this.depositChainExpiryBlock,
      required this.boostFee,
      required this.channelOpeningFee,
      required this.asset,
      required this.address});
}

class BrokerRequestSwapDepositAddressResponse {
  final String address;
  final int? issuedBlock;
  final int channelId;
  final BigInt sourceChainExpiryBlock;
  final BigInt channelOpeningFee;

  const BrokerRequestSwapDepositAddressResponse({
    required this.address,
    this.issuedBlock,
    required this.channelId,
    required this.sourceChainExpiryBlock,
    required this.channelOpeningFee,
  });

  factory BrokerRequestSwapDepositAddressResponse.fromJson(
      Map<String, dynamic> json) {
    return BrokerRequestSwapDepositAddressResponse(
      address: json['address'],
      issuedBlock: json['issued_block'],
      channelId: json['channel_id'],
      sourceChainExpiryBlock:
          BigintUtils.parse(json['source_chain_expiry_block']),
      channelOpeningFee: BigintUtils.parse(json['channel_opening_fee']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'issued_block': issuedBlock,
      'channel_id': channelId,
      'source_chain_expiry_block': sourceChainExpiryBlock.toHexDecimal,
      'channel_opening_fee': channelOpeningFee.toHexDecimal,
    };
  }

  @override
  String toString() {
    return "BrokerRequestSwapDepositAddressResponse.${toJson()}";
  }
}

class OrderInfo {
  final BigInt depth;
  final BigInt? price;

  OrderInfo({
    required this.depth,
    this.price,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      depth: BigintUtils.parse(json['depth']),
      price: BigintUtils.tryParse(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depth': depth.toString(),
      'price': price?.toString(),
    };
  }
}

class AssetInfo {
  final OrderInfo limitOrders;
  final OrderInfo rangeOrders;

  AssetInfo({
    required this.limitOrders,
    required this.rangeOrders,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> json) {
    return AssetInfo(
      limitOrders: OrderInfo.fromJson(json['limit_orders']),
      rangeOrders: OrderInfo.fromJson(json['range_orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit_orders': limitOrders.toJson(),
      'range_orders': rangeOrders.toJson(),
    };
  }
}

class PoolDepth {
  final AssetInfo asks;
  final AssetInfo bids;

  const PoolDepth({
    required this.asks,
    required this.bids,
  });

  factory PoolDepth.fromJson(Map<String, dynamic> json) {
    return PoolDepth(
      asks: AssetInfo.fromJson(json['asks']),
      bids: AssetInfo.fromJson(json['bids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asks': asks.toJson(),
      'bids': bids.toJson(),
    };
  }
}

class ChainAssetMap {
  final Map<CfAssets, BigInt?> bitcoin;
  final Map<CfAssets, BigInt?> ethereum;
  final Map<CfAssets, BigInt?> polkadot;
  final Map<CfAssets, BigInt?> arbitrum;
  final Map<CfAssets, BigInt?> solana;

  ChainAssetMap({
    required this.bitcoin,
    required this.ethereum,
    required this.polkadot,
    required this.arbitrum,
    required this.solana,
  });

  // Factory constructor to parse from JSON
  factory ChainAssetMap.fromJson(Map<String, dynamic> json) {
    return ChainAssetMap(
      bitcoin: Map<CfAssets, BigInt?>.from((json['Bitcoin'] as Map).map(
          (key, value) =>
              MapEntry(CfAssets.fromName(key), BigintUtils.tryParse(value)))),
      ethereum: Map<CfAssets, BigInt?>.from((json['Ethereum'] as Map).map(
          (key, value) =>
              MapEntry(CfAssets.fromName(key), BigintUtils.tryParse(value)))),
      polkadot: Map<CfAssets, BigInt?>.from((json['Polkadot'] as Map).map(
          (key, value) =>
              MapEntry(CfAssets.fromName(key), BigintUtils.tryParse(value)))),
      arbitrum: Map<CfAssets, BigInt?>.from((json['Arbitrum'] as Map).map(
          (key, value) =>
              MapEntry(CfAssets.fromName(key), BigintUtils.tryParse(value)))),
      solana: Map<CfAssets, BigInt?>.from((json['Solana'] as Map).map(
          (key, value) =>
              MapEntry(CfAssets.fromName(key), BigintUtils.tryParse(value)))),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Bitcoin': bitcoin.map((k, v) => MapEntry(k.name, v?.toHexDecimal)),
      'Ethereum': ethereum.map((k, v) => MapEntry(k.name, v?.toHexDecimal)),
      'Polkadot': polkadot.map((k, v) => MapEntry(k.name, v?.toHexDecimal)),
      'Arbitrum': arbitrum.map((k, v) => MapEntry(k.name, v?.toHexDecimal)),
      'Solana': solana.map((k, v) => MapEntry(k.name, v?.toHexDecimal)),
    };
  }
}

class ChainAssetFees {
  final Map<CfAssets, FeeInfo> bitcoin;
  final Map<CfAssets, FeeInfo> ethereum;
  final Map<CfAssets, FeeInfo> polkadot;
  final Map<CfAssets, FeeInfo> arbitrum;
  final Map<CfAssets, FeeInfo> solana;

  ChainAssetFees({
    required this.bitcoin,
    required this.ethereum,
    required this.polkadot,
    required this.arbitrum,
    required this.solana,
  });

  factory ChainAssetFees.fromJson(Map<String, dynamic> json) {
    return ChainAssetFees(
      bitcoin: (json[CfChain.bitcoin.name] as Map).map((key, value) => MapEntry(
          CfAssets.fromName(key),
          value == null ? FeeInfo.defaultFeeInfo() : FeeInfo.fromJson(value))),
      ethereum: (json[CfChain.ethereum.name] as Map).map((key, value) =>
          MapEntry(
              CfAssets.fromName(key),
              value == null
                  ? FeeInfo.defaultFeeInfo()
                  : FeeInfo.fromJson(value))),
      polkadot: (json[CfChain.polkadot.name] as Map).map((key, value) =>
          MapEntry(
              CfAssets.fromName(key),
              value == null
                  ? FeeInfo.defaultFeeInfo()
                  : FeeInfo.fromJson(value))),
      arbitrum: (json[CfChain.arbitrum.name] as Map).map((key, value) =>
          MapEntry(
              CfAssets.fromName(key),
              value == null
                  ? FeeInfo.defaultFeeInfo()
                  : FeeInfo.fromJson(value))),
      solana: (json[CfChain.solana.name] as Map).map((key, value) => MapEntry(
          CfAssets.fromName(key),
          value == null ? FeeInfo.defaultFeeInfo() : FeeInfo.fromJson(value))),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Bitcoin': bitcoin.map((k, v) => MapEntry(k.name, v.toJson())),
      'Ethereum': ethereum.map((k, v) => MapEntry(k.name, v.toJson())),
      'Polkadot': polkadot.map((k, v) => MapEntry(k.name, v.toJson())),
      'Arbitrum': arbitrum.map((k, v) => MapEntry(k.name, v.toJson())),
      'Solana': solana.map((k, v) => MapEntry(k.name, v.toJson())),
    };
  }
}

// export const cfSwappingEnvironment = z.object({
//   maximum_swap_amounts: chainAssetMapFactory(numberOrHex.nullable(), null),
//   network_fee_hundredth_pips: z.number(),
// });
class SwappingEnvironment {
  final ChainAssetMap maximumSwapAmounts;
  final int networkFeeHundredthPips;
  final int? swapRetryDelayBlock;
  final int? maxRetrySwapDurationBlocks;
  final int? maxSwapRequestDurationBlocks;
  const SwappingEnvironment(
      {required this.maximumSwapAmounts,
      required this.networkFeeHundredthPips,
      this.swapRetryDelayBlock,
      this.maxRetrySwapDurationBlocks,
      this.maxSwapRequestDurationBlocks});
  factory SwappingEnvironment.fromJson(Map<String, dynamic> json) {
    return SwappingEnvironment(
        maximumSwapAmounts:
            ChainAssetMap.fromJson(json["maximum_swap_amounts"]),
        networkFeeHundredthPips:
            IntUtils.parse(json["network_fee_hundredth_pips"]),
        swapRetryDelayBlock: IntUtils.tryParse(json["swap_retry_delay_blocks"]),
        maxRetrySwapDurationBlocks:
            IntUtils.tryParse(json["max_swap_retry_duration_blocks"]),
        maxSwapRequestDurationBlocks:
            IntUtils.parse(json["max_swap_request_duration_blocks"]));
  }
  Map<String, dynamic> toJson() {
    return {
      "maximum_swap_amounts": maximumSwapAmounts.toJson(),
      "network_fee_hundredth_pips": networkFeeHundredthPips,
      "swap_retry_delay_blocks": swapRetryDelayBlock,
      "max_swap_retry_duration_blocks": maxRetrySwapDurationBlocks,
      "max_swap_request_duration_blocks": maxSwapRequestDurationBlocks
    };
  }
}

class FundingEnvironment {
  final BigInt redemptionTax;
  final BigInt minimumFundingAmount;
  const FundingEnvironment(
      {required this.redemptionTax, required this.minimumFundingAmount});
  factory FundingEnvironment.fromJson(Map<String, dynamic> json) {
    return FundingEnvironment(
        redemptionTax: BigintUtils.parse(json["redemption_tax"]),
        minimumFundingAmount:
            BigintUtils.parse(json["minimum_funding_amount"]));
  }
  Map<String, dynamic> toJson() {
    return {
      "redemption_tax": redemptionTax.toHexDecimal,
      "minimum_funding_amount": minimumFundingAmount.toHexDecimal
    };
  }
}

class FeeInfo {
  final int limitOrderFeeHundredthPips;
  final int rangeOrderFeeHundredthPips;
  final FeeInput rangeOrderTotalFeesEarned;
  final FeeInput limitOrderTotalFeesEarned;
  final FeeInput rangeTotalSwapInputs;
  final FeeInput limitTotalSwapInputs;
  final UncheckedAssetAndChain quoteAsset;

  FeeInfo({
    required this.limitOrderFeeHundredthPips,
    required this.rangeOrderFeeHundredthPips,
    required this.rangeOrderTotalFeesEarned,
    required this.limitOrderTotalFeesEarned,
    required this.rangeTotalSwapInputs,
    required this.limitTotalSwapInputs,
    required this.quoteAsset,
  });
  factory FeeInfo.fromJson(Map<String, dynamic> json) {
    return FeeInfo(
      limitOrderFeeHundredthPips: json["limit_order_fee_hundredth_pips"],
      rangeOrderFeeHundredthPips: json["range_order_fee_hundredth_pips"],
      rangeOrderTotalFeesEarned:
          FeeInput.fromJson(json["range_order_total_fees_earned"]),
      limitOrderTotalFeesEarned:
          FeeInput.fromJson(json["limit_order_total_fees_earned"]),
      rangeTotalSwapInputs: FeeInput.fromJson(json["range_total_swap_inputs"]),
      limitTotalSwapInputs: FeeInput.fromJson(json["limit_total_swap_inputs"]),
      quoteAsset: UncheckedAssetAndChain.fromJson(json["quote_asset"]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "limit_order_fee_hundredth_pips": limitOrderFeeHundredthPips,
      "range_order_fee_hundredth_pips": rangeOrderFeeHundredthPips,
      "range_order_total_fees_earned": rangeOrderTotalFeesEarned.toJson(),
      "limit_order_total_fees_earned": limitOrderTotalFeesEarned.toJson(),
      "range_total_swap_inputs": rangeTotalSwapInputs.toJson(),
      "limit_total_swap_inputs": limitTotalSwapInputs.toJson(),
      "quote_asset": quoteAsset.toJson()
    };
  }

  // Factory constructor to return default values
  factory FeeInfo.defaultFeeInfo() {
    return FeeInfo(
      limitOrderFeeHundredthPips: 0,
      rangeOrderFeeHundredthPips: 0,
      rangeOrderTotalFeesEarned:
          FeeInput(base: BigInt.zero, quote: BigInt.zero),
      limitOrderTotalFeesEarned:
          FeeInput(base: BigInt.zero, quote: BigInt.zero),
      rangeTotalSwapInputs: FeeInput(base: BigInt.zero, quote: BigInt.zero),
      limitTotalSwapInputs: FeeInput(base: BigInt.zero, quote: BigInt.zero),
      quoteAsset: UncheckedAssetAndChain(chain: 'Ethereum', asset: 'USDC'),
    );
  }
}

class FeeInput {
  final BigInt base;
  final BigInt quote;
  const FeeInput({required this.base, required this.quote});
  factory FeeInput.fromJson(Map<String, dynamic> json) {
    return FeeInput(
      base: BigintUtils.parse(json['base']),
      quote: BigintUtils.parse(json['quote']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base.toHexDecimal,
      'quote': quote.toHexDecimal,
    };
  }
}

class PoolsEnvironment {
  final ChainAssetFees? fees;
  const PoolsEnvironment({this.fees});
  factory PoolsEnvironment.fromJson(Map<String, dynamic> json) {
    return PoolsEnvironment(
        fees: json["fees"] == null
            ? null
            : ChainAssetFees.fromJson(json["fees"]));
  }

  Map<String, dynamic> toJson() {
    return {"fees": fees?.toJson()};
  }
}

class IngressEgressEnvironment {
  final ChainAssetMap minimumDepositAmounts;
  final ChainAssetMap ingressFees;
  final ChainAssetMap egressFees;
  final ChainAssetMap egressDustLimits;
  final Map<CfChain, int?> witnessSafetyMargins;
  final Map<CfChain, BigInt> channelOpeningFees;

  const IngressEgressEnvironment(
      {required this.minimumDepositAmounts,
      required this.ingressFees,
      required this.egressDustLimits,
      required this.egressFees,
      required this.witnessSafetyMargins,
      required this.channelOpeningFees});
  factory IngressEgressEnvironment.fromJson(Map<String, dynamic> json) {
    return IngressEgressEnvironment(
        minimumDepositAmounts:
            ChainAssetMap.fromJson(json["minimum_deposit_amounts"]),
        ingressFees: ChainAssetMap.fromJson(json["ingress_fees"]),
        egressDustLimits: ChainAssetMap.fromJson(json["egress_dust_limits"]),
        egressFees: ChainAssetMap.fromJson(json["egress_fees"]),
        witnessSafetyMargins: (json["witness_safety_margins"] as Map).map((k,
                v) =>
            MapEntry<CfChain, int?>(CfChain.fromName(k), IntUtils.tryParse(v))),
        channelOpeningFees: (json["channel_opening_fees"] as Map).map((k, v) =>
            MapEntry<CfChain, BigInt>(
                CfChain.fromName(k), BigintUtils.tryParse(v) ?? BigInt.zero)));
  }
  Map<String, dynamic> toJson() {
    return {
      "minimum_deposit_amounts": minimumDepositAmounts.toJson(),
      "ingress_fees": ingressFees.toJson(),
      "egress_dust_limits": egressDustLimits.toJson(),
      "egress_fees": egressFees.toJson(),
      "channel_opening_fees":
          channelOpeningFees.map((k, v) => MapEntry(k.name, v.toHexDecimal)),
      "witness_safety_margins":
          witnessSafetyMargins.map((k, v) => MapEntry(k.name, v))
    };
  }
}

class Environment {
  final IngressEgressEnvironment ingressEgress;
  final SwappingEnvironment swapping;
  final FundingEnvironment funding;
  final PoolsEnvironment pools;
  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
        ingressEgress:
            IngressEgressEnvironment.fromJson(json["ingress_egress"]),
        swapping: SwappingEnvironment.fromJson(json["swapping"]),
        funding: FundingEnvironment.fromJson(json["funding"]),
        pools: PoolsEnvironment.fromJson(json["pools"]));
  }
  const Environment(
      {required this.ingressEgress,
      required this.swapping,
      required this.funding,
      required this.pools});
  Map<String, dynamic> toJson() {
    return {
      "ingress_egress": ingressEgress.toJson(),
      "swapping": swapping.toJson(),
      "funding": funding.toJson(),
      "pools": pools.toJson()
    };
  }
}

class SwapRateResponse {
  final BigInt? intermediary;
  final BigInt output;

  SwapRateResponse({
    this.intermediary,
    required this.output,
  });

  // Factory constructor to parse from JSON
  factory SwapRateResponse.fromJson(Map<String, dynamic> json) {
    return SwapRateResponse(
      intermediary: BigintUtils.tryParse(json['intermediary']),
      output: BigintUtils.parse(json['output'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intermediary': intermediary?.toString(),
      'output': output.toString(),
    };
  }
}

class SwapRateV2Response {
  final SwapRateV2Fee egressFee;
  final SwapRateV2Fee ingressFee;
  final BigInt? intermediary;
  final SwapRateV2Fee networkFee;
  final BigInt output;

  SwapRateV2Response({
    required this.egressFee,
    required this.ingressFee,
    this.intermediary,
    required this.networkFee,
    required this.output,
  });

  factory SwapRateV2Response.fromJson(Map<String, dynamic> json) {
    return SwapRateV2Response(
      egressFee: SwapRateV2Fee.fromJson(json['egress_fee']),
      ingressFee: SwapRateV2Fee.fromJson(json['ingress_fee']),
      intermediary: BigintUtils.tryParse(json['intermediary']),
      networkFee: SwapRateV2Fee.fromJson(json['network_fee']),
      output: BigintUtils.parse(json['output']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'egress_fee': egressFee.toJson(),
      'ingress_fee': ingressFee.toJson(),
      'intermediary': intermediary?.toHexDecimal,
      'network_fee': networkFee.toJson(),
      'output': output.toHexDecimal,
    };
  }
}

class SwapRateV2Fee {
  final BigInt amount;
  final String chain;
  final String asset;

  SwapRateV2Fee(
      {required this.amount, required this.chain, required this.asset});

  // Factory constructor to parse from JSON
  factory SwapRateV2Fee.fromJson(Map<String, dynamic> json) {
    return SwapRateV2Fee(
        amount: BigintUtils.parse(json['amount']),
        asset: json["asset"],
        chain: json["chain"]);
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount.toString(),
    };
  }
}

class BoostPoolAmountResponse {
  final String accountId;
  final BigInt amount;

  BoostPoolAmountResponse({
    required this.accountId,
    required this.amount,
  });

  // Factory constructor to parse from JSON
  factory BoostPoolAmountResponse.fromJson(Map<String, dynamic> json) {
    return BoostPoolAmountResponse(
      accountId: json['account_id'],
      amount: BigintUtils.parse(json['amount']), // u256 is parsed as BigInt
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'amount': amount.toHexDecimal,
    };
  }
}

class PendingWithdrawalsResponse {
  final String accountId;
  final List<BigInt> pendingDeposits;

  PendingWithdrawalsResponse({
    required this.accountId,
    required this.pendingDeposits,
  });

  // Factory constructor to parse from JSON
  factory PendingWithdrawalsResponse.fromJson(Map<String, dynamic> json) {
    return PendingWithdrawalsResponse(
      accountId: json['account_id'],
      pendingDeposits: (json["pending_deposits"] as List)
          .map((e) => BigintUtils.parse(e))
          .toList(), // u256 is parsed as BigInt
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'pending_deposits': pendingDeposits.map((e) => e.toHexDecimal).toList(),
    };
  }
}

class DepositsPendingFinalizationResponse {
  final int depositId;
  final List<BoostPoolAmountResponse> owedAmounts;

  DepositsPendingFinalizationResponse({
    required this.depositId,
    required this.owedAmounts,
  });

  // Factory constructor to parse from JSON
  factory DepositsPendingFinalizationResponse.fromJson(
      Map<String, dynamic> json) {
    return DepositsPendingFinalizationResponse(
      depositId: json['deposit_id'],
      owedAmounts: (json["owed_amounts"] as List)
          .map((e) => BoostPoolAmountResponse.fromJson(e))
          .toList(), // u256 is parsed as BigInt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deposit_id': depositId,
      'owed_amounts': owedAmounts.map((e) => e.toJson()).toList(),
    };
  }
}

class PendingFeesResponse {
  final BigInt depositId;
  final List<BoostPoolAmountResponse> fees;

  PendingFeesResponse({
    required this.depositId,
    required this.fees,
  });

  // Factory constructor to parse from JSON
  factory PendingFeesResponse.fromJson(Map<String, dynamic> json) {
    return PendingFeesResponse(
      depositId: BigintUtils.parse(json['deposit_id']),
      fees: (json["fees"] as List)
          .map((e) => BoostPoolAmountResponse.fromJson(e))
          .toList(), // u256 is parsed as BigInt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deposit_id': depositId.toHexDecimal,
      'fees': fees.map((e) => e.toJson()).toList(),
    };
  }
}

class BoostPoolDetailsResponse {
  final String asset;
  final String chain;
  final int feeTier;
  final List<BoostPoolAmountResponse> availableAmounts;
  final List<DepositsPendingFinalizationResponse> depositsPendingFinalization;
  final List<PendingWithdrawalsResponse> pendingWithdrawals;

  BoostPoolDetailsResponse({
    required this.asset,
    required this.chain,
    required this.feeTier,
    required this.availableAmounts,
    required this.depositsPendingFinalization,
    required this.pendingWithdrawals,
  });

  // Factory constructor to parse from JSON
  factory BoostPoolDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BoostPoolDetailsResponse(
      asset: json['asset'],
      chain: json['chain'],
      feeTier: json["fee_tier"],
      availableAmounts: (json['available_amounts'] as List)
          .map((item) => BoostPoolAmountResponse.fromJson(item))
          .toList(),
      depositsPendingFinalization:
          (json['deposits_pending_finalization'] as List)
              .map((item) => DepositsPendingFinalizationResponse.fromJson(item))
              .toList(),
      pendingWithdrawals: (json['pending_withdrawals'] as List)
          .map((item) => PendingWithdrawalsResponse.fromJson(item))
          .toList(),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'chain': chain,
      "fee_tier": feeTier,
      'available_amounts':
          availableAmounts.map((item) => item.toJson()).toList(),
      'deposits_pending_finalization':
          depositsPendingFinalization.map((item) => item.toJson()).toList(),
      'pending_withdrawals':
          pendingWithdrawals.map((item) => item.toJson()).toList(),
    };
  }
}

class BoostPoolPendingFeesResponse {
  final String asset;
  final String chain;
  final int feeTier;
  final List<PendingFeesResponse> pendingFees;

  BoostPoolPendingFeesResponse({
    required this.asset,
    required this.chain,
    required this.feeTier,
    required this.pendingFees,
  });

  // Factory constructor to parse from JSON
  factory BoostPoolPendingFeesResponse.fromJson(Map<String, dynamic> json) {
    return BoostPoolPendingFeesResponse(
      asset: json['asset'],
      chain: json['chain'],
      feeTier: json["fee_tier"],
      pendingFees: (json['pending_fees'] as List)
          .map((item) => PendingFeesResponse.fromJson(item))
          .toList(),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'chain': chain,
      "fee_tier": feeTier,
      'pending_fees': pendingFees.map((item) => item.toJson()).toList(),
    };
  }
}

class BoostPoolDepthResponse {
  final String asset;
  final String chain;
  final int tier;
  final BigInt availableAmounts;

  BoostPoolDepthResponse({
    required this.asset,
    required this.chain,
    required this.tier,
    required this.availableAmounts,
  });

  // Factory constructor to parse from JSON
  factory BoostPoolDepthResponse.fromJson(Map<String, dynamic> json) {
    return BoostPoolDepthResponse(
      asset: json['asset'],
      chain: json['chain'],
      tier: json["tier"],
      availableAmounts: BigintUtils.parse(json["available_amount"]),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'chain': chain,
      "tier": tier,
      'available_amount': availableAmounts.toHexDecimal,
    };
  }
}

class RangeOrderResponse {
  final String id;
  final Range range;
  final BigInt liquidity;
  final FeesEarnedResonse feesEarned;
  final String lp;
  final String type;

  RangeOrderResponse({
    required this.id,
    required this.range,
    required this.liquidity,
    required this.feesEarned,
    required this.lp,
  }) : type = 'range';

  // Factory constructor to parse from JSON
  factory RangeOrderResponse.fromJson(Map<String, dynamic> json) {
    return RangeOrderResponse(
      id: json['id'],
      range: Range.fromJson(json['range']),
      liquidity: BigintUtils.parse(json['liquidity']),
      feesEarned: FeesEarnedResonse.fromJson(json['fees_earned']),
      lp: json['lp'],
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'range': range.toJson(),
      'liquidity': liquidity.toString(),
      'fees_earned': feesEarned.toJson(),
      'lp': lp,
      'type': type, // Fixed value 'range'
    };
  }
}

class Range {
  final int start;
  final int end;

  Range({
    required this.start,
    required this.end,
  });

  // Factory constructor to parse from JSON
  factory Range.fromJson(Map<String, dynamic> json) {
    return Range(
      start: json['start'],
      end: json['end'],
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class FeesEarnedResonse {
  final BigInt base;
  final BigInt quote;

  FeesEarnedResonse({
    required this.base,
    required this.quote,
  });

  // Factory constructor to parse from JSON
  factory FeesEarnedResonse.fromJson(Map<String, dynamic> json) {
    return FeesEarnedResonse(
      base: BigintUtils.parse(json['base']),
      quote: BigintUtils.parse(json['quote']),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {'base': base.toHexDecimal, 'quote': quote.toHexDecimal};
  }
}

class PoolOrdersResponse {
  final LimitOrdersResponse limitOrders;
  final List<RangeOrderResponse> rangeOrders;

  PoolOrdersResponse({
    required this.limitOrders,
    required this.rangeOrders,
  });

  // Factory constructor to parse from JSON
  factory PoolOrdersResponse.fromJson(Map<String, dynamic> json) {
    return PoolOrdersResponse(
      limitOrders: LimitOrdersResponse.fromJson(
          json['limit_orders'] as Map<String, dynamic>),
      rangeOrders: (json['range_orders'] as List)
          .map((order) =>
              RangeOrderResponse.fromJson(order as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'limit_orders': limitOrders.toJson(),
      'range_orders': rangeOrders.map((order) => order.toJson()).toList(),
    };
  }
}

class LimitOrdersResponse {
  final List<LimitOrderResponse>
      asks; // Define these based on ask/bid structure
  final List<LimitOrderResponse> bids;

  LimitOrdersResponse({
    required this.asks,
    required this.bids,
  });

  // Factory constructor to parse from JSON
  factory LimitOrdersResponse.fromJson(Map<String, dynamic> json) {
    return LimitOrdersResponse(
      asks: (json['asks'] as List)
          .map((e) => LimitOrderResponse.fromJson(e))
          .toList(),
      bids: (json['bids'] as List)
          .map((e) => LimitOrderResponse.fromJson(e))
          .toList(), //
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'asks': asks,
      'bids': bids,
    };
  }
}

class LimitOrderResponse {
  final String id;
  final int tick;
  final BigInt sellAmount;
  final BigInt feesEarned;
  final BigInt originalSellAmount;
  final String lp;

  const LimitOrderResponse({
    required this.id,
    required this.tick,
    required this.sellAmount,
    required this.feesEarned,
    required this.originalSellAmount,
    required this.lp,
  });

  // Factory constructor to parse from JSON
  factory LimitOrderResponse.fromJson(Map<String, dynamic> json) {
    return LimitOrderResponse(
        id: json['id'].toString(),
        tick: json['tick'],
        sellAmount: BigintUtils.parse(json['sell_amount']),
        feesEarned: BigintUtils.parse(json['fees_earned']),
        lp: json["lp"],
        originalSellAmount: BigintUtils.parse(json['original_sell_amount']));
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tick": tick,
      "sell_amount": sellAmount.toHexDecimal,
      "fees_earned": feesEarned.toHexDecimal,
      "lp": lp,
      "original_sell_amount": originalSellAmount.toHexDecimal
    };
  }
}

class PoolPriceV2Response {
  final BigInt? sell; // Nullable field
  final BigInt? buy; // Nullable field
  final BigInt rangeOrder;
  final UncheckedAssetAndChain baseAsset;
  final UncheckedAssetAndChain quoteAsset;

  PoolPriceV2Response({
    required this.sell,
    required this.buy,
    required this.rangeOrder,
    required this.baseAsset,
    required this.quoteAsset,
  });

  // Factory constructor to parse from JSON
  factory PoolPriceV2Response.fromJson(Map<String, dynamic> json) {
    return PoolPriceV2Response(
      sell: BigintUtils.tryParse(json['sell']),
      buy: BigintUtils.tryParse(json['buy']),
      rangeOrder: BigintUtils.parse(json['range_order']),
      baseAsset: UncheckedAssetAndChain.fromJson(json['base_asset']),
      quoteAsset: UncheckedAssetAndChain.fromJson(json['quote_asset']),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'sell': sell?.toHexDecimal,
      'buy': buy?.toHexDecimal,
      'range_order': rangeOrder.toHexDecimal,
      'base_asset': baseAsset.toJson(),
      'quote_asset': quoteAsset.toJson(),
    };
  }
}

class RuntimeVersionResponse {
  final String specName;
  final String implName;
  final int authoringVersion;
  final int specVersion;
  final int implVersion;
  final List<RuntimeApiResponse> apis;
  final int transactionVersion;
  final int stateVersion;

  RuntimeVersionResponse({
    required this.specName,
    required this.implName,
    required this.authoringVersion,
    required this.specVersion,
    required this.implVersion,
    required this.apis,
    required this.transactionVersion,
    required this.stateVersion,
  });

  // Factory constructor to parse from JSON
  factory RuntimeVersionResponse.fromJson(Map<String, dynamic> json) {
    return RuntimeVersionResponse(
      specName: json['specName'],
      implName: json['implName'],
      authoringVersion: json['authoringVersion'],
      specVersion: json['specVersion'],
      implVersion: json['implVersion'],
      apis: (json['apis'] as List)
          .map((api) => RuntimeApiResponse.fromJson(api as List<dynamic>))
          .toList(),
      transactionVersion: json['transactionVersion'],
      stateVersion: json['stateVersion'],
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'specName': specName,
      'implName': implName,
      'authoringVersion': authoringVersion,
      'specVersion': specVersion,
      'implVersion': implVersion,
      'apis': apis.map((api) => api.toJson()).toList(),
      'transactionVersion': transactionVersion,
      'stateVersion': stateVersion,
    };
  }
}

class RuntimeApiResponse {
  final String hexString;
  final int version;

  const RuntimeApiResponse({required this.hexString, required this.version});

  // Factory constructor to parse from JSON
  factory RuntimeApiResponse.fromJson(List<dynamic> json) {
    return RuntimeApiResponse(
      hexString: json[0],
      version: json[1],
    );
  }

  // Convert Dart object to JSON
  List<dynamic> toJson() {
    return [hexString, version];
  }
}
