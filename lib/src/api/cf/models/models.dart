import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// Represents the result of a Substrate transaction submission.
class SubtrateTransactionSubmitionResult {
  /// The extrinsic associated with the transaction.
  final String extrinsic;

  /// The block in which the transaction was included.
  final String block;

  /// The block number of the transaction.
  final int blockNumber;

  /// A list of events related to the transaction.
  final List<SubstrateEvent> events;

  /// The hash of the transaction.
  final String transactionHash;

  /// Constructor for initializing all the fields.
  const SubtrateTransactionSubmitionResult({
    required this.events,
    required this.block,
    required this.extrinsic,
    required this.blockNumber,
    required this.transactionHash,
  });
}

/// Parameters for configuring an EVM transaction.
class EVMTransactionParams {
  /// Optional gas limit for the transaction.
  final int? gasLimit;

  /// Optional gas price for the transaction.
  final BigInt? gasPrice;

  /// Optional maximum fee per gas for EIP-1559 transactions.
  final BigInt? maxFeePerGas;

  /// Optional maximum priority fee per gas for EIP-1559 transactions.
  final BigInt? maxPriorityFeePerGas;

  /// Optional account nonce for the transaction.
  final int? accountNonce;

  /// Optional access list entries for the transaction (EIP-2930).
  final List<AccessListEntry>? accessListEntry;

  /// The type of Ethereum transaction (Legacy, EIP-2930, or EIP-1559).
  final ETHTransactionType transactionType;

  /// Optional fee rate for EIP-1559 transactions.
  final EIP1559FeeRate? feeRate;

  /// Private constructor for internal use.
  EVMTransactionParams._({
    this.gasLimit,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.accountNonce,
    required this.transactionType,
    List<AccessListEntry>? accessListEntry,
    this.feeRate,
  }) : accessListEntry = accessListEntry?.immutable;

  /// Factory constructor for legacy transactions.
  factory EVMTransactionParams.legacy({
    BigInt? gasPrice,
    int? gasLimit,
    int? accountNonce,
  }) {
    return EVMTransactionParams._(
      transactionType: ETHTransactionType.legacy,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      accountNonce: accountNonce,
    );
  }

  /// Factory constructor for EIP-2930 transactions.
  factory EVMTransactionParams.eip2930({
    BigInt? gasPrice,
    int? gasLimit,
    int? accountNonce,
    List<AccessListEntry>? accessListEntry,
  }) {
    return EVMTransactionParams._(
      transactionType: ETHTransactionType.eip2930,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      accessListEntry: accessListEntry,
      accountNonce: accountNonce,
    );
  }

  /// Factory constructor for EIP-1559 transactions.
  factory EVMTransactionParams.eip1559({
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    int? gasLimit,
    int? accountNonce,
    List<AccessListEntry>? accessListEntry,
    EIP1559FeeRate? feeRate,
  }) {
    if (maxFeePerGas == null && maxPriorityFeePerGas != null ||
        maxFeePerGas != null && maxPriorityFeePerGas == null) {
      throw DartCfPluginException(
          "For EIP-1559, both maxFeePerGas and maxPriorityFeePerGas are required.");
    } else if (maxFeePerGas != null && feeRate != null) {
      throw DartCfPluginException(
          "For automatically filled fees, maxFeePerGas and maxPriorityFeePerGas must be left unspecified.");
    }
    return EVMTransactionParams._(
      transactionType: ETHTransactionType.eip1559,
      gasLimit: gasLimit,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      accessListEntry: accessListEntry,
      accountNonce: accountNonce,
      feeRate: feeRate,
    );
  }

  /// Fills the transaction builder with the provided parameters.
  void filledTransaction(ETHTransactionBuilder transaction) {
    if (accountNonce != null) {
      transaction.setNonce(accountNonce!);
    }
    if (gasLimit != null) {
      transaction.setGasLimit(BigInt.from(gasLimit!));
    }
    if (gasPrice != null) {
      transaction.setGasPrice(gasPrice!);
    }
    if (maxFeePerGas != null) {
      transaction.setEIP1559FeeDetails(maxFeePerGas!, maxPriorityFeePerGas!);
    }
    if (accessListEntry != null) {
      transaction.setAccessList(accessListEntry);
    }
  }
}

class GetPendingRedemptionResult {
  final BigInt amount;
  final SolidityAddress redeemAddress;
  final int startTime;
  final int expiryTime;
  final SolidityAddress executor;

  const GetPendingRedemptionResult(
      {required this.amount,
      required this.redeemAddress,
      required this.startTime,
      required this.executor,
      required this.expiryTime});
}

class EIP712DomainResponse {
  final List<int> fields;
  final String name;
  final String version;
  final BigInt chainId;
  final ETHAddress verifyingContract;
  final List<int> salt;
  final List<BigInt> extensions;
  EIP712DomainResponse(
      {required List<int> fields,
      required this.name,
      required this.verifyingContract,
      required this.chainId,
      required List<int> salt,
      required List<BigInt> extensions,
      required this.version})
      : fields = fields.immutable,
        salt = salt.immutable,
        extensions = extensions.immutable;
}
