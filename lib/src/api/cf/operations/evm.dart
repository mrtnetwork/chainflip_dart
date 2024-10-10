import 'package:blockchain_utils/helper/helper.dart';
import 'package:chainflip_dart/src/types/types/asset_and_chain.dart';
import 'package:chainflip_dart/src/api/cf/constant/const.dart';
import 'package:chainflip_dart/src/api/cf/models/models.dart';
import 'package:chainflip_dart/src/api/cf/operations/substrate.dart';
import 'package:chainflip_dart/src/types/types/chain_flip_networks.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// Enum representing the types of Ethereum operations.
enum EvmOperationType { call, execute }

/// Abstract class representing a generic Ethereum operation.
abstract class EvmOperation {
  /// The ABI function fragment associated with this operation.
  final AbiFunctionFragment fragment;

  /// The type of the operation (call or execute).
  final EvmOperationType type;

  /// Constructor for EvmOperation.
  const EvmOperation({required this.fragment, required this.type});
}

/// Abstract class representing a call operation in Ethereum.
abstract class EvmCallOperation<RESULT> extends EvmOperation {
  /// Constructor for EvmCallOperation, initializing the fragment and type.
  const EvmCallOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment, type: EvmOperationType.call);

  /// Processes the response from the Ethereum call operation.
  RESULT onResponse(List<dynamic> result) {
    return result[0] as RESULT; // Assumes the first element is the result.
  }

  /// Returns the input parameters for the operation.
  List<dynamic> input();
}

/// Abstract class representing an execute operation in Ethereum.
abstract class EvmExcuteOperation extends EvmOperation {
  /// Constructor for EvmExcuteOperation, initializing the fragment and type.
  const EvmExcuteOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment, type: EvmOperationType.execute);

  /// Returns the input parameters for the operation.
  List<dynamic> input({CfNetwork? network});

  /// Encodes the parameters for the execute operation.
  List<int> encodeParams(CfNetwork network) {
    return fragment.encode(input(
        network: network)); // Encodes input parameters using the fragment.
  }
}

/// Abstract class for operations on the flip contract that involve calling.
abstract class EVMERC20ContractOperation<RESULT>
    extends EvmCallOperation<RESULT> {
  /// Constructor for EvmFlipContractOperation, initializing the fragment.
  EVMERC20ContractOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment);
}

/// Abstract class for operations on the flip contract that involve executing.
abstract class EVMERC20ContractExcuteOperation<RESULT>
    extends EvmExcuteOperation {
  /// Constructor for EvmFlipContractExcuteOperation, initializing the fragment.
  EVMERC20ContractExcuteOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment);
}

/// Class to get the token balance of a specific address.
class EvmGetTokenBalanceOperation extends EVMERC20ContractOperation<BigInt> {
  /// The Ethereum address for which the balance is requested.
  final ETHAddress address;

  /// Private constructor to initialize the class.
  EvmGetTokenBalanceOperation._(
      {required this.address, required AbiFunctionFragment fragment})
      : super(fragment: fragment);

  /// Factory constructor to create an instance of the operation.
  factory EvmGetTokenBalanceOperation(ETHAddress address) {
    return EvmGetTokenBalanceOperation._(
        address: address, fragment: CfApiConst.erc20BalaceFragment);
  }

  @override
  List input() {
    return [address];
  }
}

class EvmGetTokenNameOperation extends EVMERC20ContractOperation<String> {
  EvmGetTokenNameOperation() : super(fragment: CfApiConst.tokenName);

  @override
  List input() {
    return [];
  }
}

class EvmGetTokenSymbolOperation extends EVMERC20ContractOperation<String> {
  EvmGetTokenSymbolOperation() : super(fragment: CfApiConst.tokenSymbol);

  @override
  List input() {
    return [];
  }
}

class EvmGetTokenDecimalsOperation extends EVMERC20ContractOperation<int> {
  EvmGetTokenDecimalsOperation() : super(fragment: CfApiConst.tokenDecimals);

  @override
  List input() {
    return [];
  }

  @override
  int onResponse(List result) {
    return (result[0] as BigInt).toInt();
  }
}

class EvmGetEIP712DomainOperation
    extends EVMERC20ContractOperation<EIP712DomainResponse> {
  EvmGetEIP712DomainOperation() : super(fragment: CfApiConst.eip712Domain);

  @override
  List input() {
    return [];
  }

  @override
  EIP712DomainResponse onResponse(List result) {
    final List<int> fields = List<int>.from(result[0]);
    final String name = result[1];
    final String version = result[2];
    final BigInt chainId = result[3];
    final ETHAddress verifyingContract =
        (result[4] as SolidityAddress).toEthereumAddress();
    final List<int> salt = List<int>.from(result[5]);
    final List<BigInt> extensions = List<BigInt>.from(result[6]);

    return EIP712DomainResponse(
        fields: fields,
        name: name,
        verifyingContract: verifyingContract,
        chainId: chainId,
        salt: salt,
        extensions: extensions,
        version: version);
  }
}

/// Class to get the allowance of a specific address for a token contract.
class EvmGetAllowanceOperation extends EVMERC20ContractOperation<BigInt> {
  /// The Ethereum address for which the allowance is checked.
  final ETHAddress address;

  /// Private constructor to initialize the class.
  EvmGetAllowanceOperation._(
      {required this.address, required AbiFunctionFragment fragment})
      : super(fragment: fragment);

  /// Factory constructor to create an instance of the operation.
  factory EvmGetAllowanceOperation(
      {required ETHAddress contractAddress, required ETHAddress address}) {
    return EvmGetAllowanceOperation._(
        address: address, fragment: CfApiConst.getAllowance);
  }

  @override
  List input() {
    return [address]; // The input parameter for the allowance query.
  }
}

/// Class to transfer tokens to a specified address.
class EvmTransferTokenOperation extends EVMERC20ContractExcuteOperation {
  /// The destination address where tokens will be sent.
  final ETHAddress destination;

  /// The amount of tokens to transfer.
  final BigInt tokenAmount;

  /// Private constructor to initialize the class.
  EvmTransferTokenOperation(
      {required this.destination, required this.tokenAmount})
      : super(fragment: CfApiConst.transferFragment);

  @override
  List input({CfNetwork? network}) {
    return [destination, tokenAmount]; // The input parameters for the transfer.
  }
}

/// Class to increase the allowance of a specific address.
class EvmIncreaseAllowanceOperation extends EVMERC20ContractExcuteOperation {
  /// The Ethereum address for which the allowance is increased.
  final ETHAddress spender;

  /// The amount to add to the allowance.
  final BigInt addedAmount;

  EvmIncreaseAllowanceOperation(
      {required this.spender, required this.addedAmount})
      : super(fragment: CfApiConst.increaseAllowance);

  @override
  List input({CfNetwork? network}) {
    return [spender, addedAmount];
  }
}

/// Class to increase the allowance of a specific address.
class EvmApproveOperation extends EVMERC20ContractExcuteOperation {
  /// The Ethereum address for which the allowance is increased.
  final ETHAddress spender;

  /// The amount to add to the allowance.
  final BigInt addedAmount;

  EvmApproveOperation({required this.spender, required this.addedAmount})
      : super(fragment: CfApiConst.approve);

  @override
  List input({CfNetwork? network}) {
    return [spender, addedAmount];
  }
}

/// Class to decrease the allowance of a specific address.
class EvmDecreaseAllowanceOperation extends EVMERC20ContractExcuteOperation {
  /// The Ethereum address for which the allowance is decreased.
  final ETHAddress address;

  /// The amount to subtract from the allowance.
  final BigInt subtractedValue;

  /// Private constructor to initialize the class.
  EvmDecreaseAllowanceOperation(
      {required this.address, required this.subtractedValue})
      : super(fragment: CfApiConst.decreaseAllowance);

  @override
  List input({CfNetwork? network}) {
    return [
      address,
      subtractedValue
    ]; // The input parameters for decreasing allowance.
  }
}

/// Abstract class for executing operations related to the state chain gateway.
abstract class EvmStateChainGatewayExcuteOperation extends EvmExcuteOperation {
  EvmStateChainGatewayExcuteOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment);
}

/// Abstract class for calling operations related to the state chain gateway.
abstract class EvmStateChainGatewayCallOperation<RESULT>
    extends EvmCallOperation<RESULT> {
  EvmStateChainGatewayCallOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment);
}

/// Class to fund a state chain account with a specific amount.
class EvmStateChainGatewayFundStateChainAccountOperation
    extends EvmStateChainGatewayExcuteOperation {
  /// The ID of the node being funded.
  final SubstrateAddress nodeId;

  /// The amount to fund the state chain account.
  final BigInt amount;

  EvmStateChainGatewayFundStateChainAccountOperation(
      {required this.nodeId, required this.amount})
      : super(fragment: CfApiConst.fundStateChainAccount);

  @override
  List input({CfNetwork? network}) {
    return [
      nodeId.toBytes(),
      amount
    ]; // Input parameters for the funding operation.
  }
}

/// Class to execute a redemption operation on the state chain gateway.
class EvmStateChainGatewayExecuteRedemptionOperation
    extends EvmStateChainGatewayExcuteOperation {
  /// The ID of the node involved in the redemption.
  final SubstrateAddress nodeId;

  EvmStateChainGatewayExecuteRedemptionOperation({required this.nodeId})
      : super(fragment: CfApiConst.executeRedemption);

  @override
  List input({CfNetwork? network}) {
    return [nodeId.toBytes()]; // Input parameters for the redemption execution.
  }
}

/// Class to get the minimum funding required for the state chain gateway.
class EvmStateChainGatewayGetMinimumFundingOperation
    extends EvmStateChainGatewayCallOperation<BigInt> {
  EvmStateChainGatewayGetMinimumFundingOperation()
      : super(fragment: CfApiConst.getMinimumFunding);

  @override
  List input() {
    return []; // No input parameters required for this operation.
  }
}

/// Class to get pending redemption details for a specific node.
class EvmStateChainGatewayGetPendingRedemptionOperation
    extends EvmStateChainGatewayCallOperation<GetPendingRedemptionResult> {
  /// The ID of the node for which pending redemption is queried.
  final SubstrateAddress nodeId;

  EvmStateChainGatewayGetPendingRedemptionOperation({required this.nodeId})
      : super(fragment: CfApiConst.getPendingRedemption);

  @override
  List input() {
    return [
      nodeId.toBytes()
    ]; // Input parameters for querying pending redemption.
  }

  @override
  GetPendingRedemptionResult onResponse(List result) {
    // Destructuring the result into expected values.
    final redemptionResult = result[0];
    final BigInt amount = redemptionResult[0];
    final SolidityAddress redeemAddress = redemptionResult[1];
    final BigInt startTime = redemptionResult[2];
    final BigInt expiryTime = redemptionResult[3];
    final SolidityAddress executor = redemptionResult[4];

    // Returning the structured result.
    return GetPendingRedemptionResult(
        amount: amount,
        redeemAddress: redeemAddress,
        startTime: startTime.toInt(),
        executor: executor,
        expiryTime: expiryTime.toInt());
  }
}

/// Class to get the redemption delay for operations on the state chain gateway.
class GetRedemptionDelayOperation
    extends EvmStateChainGatewayCallOperation<int> {
  GetRedemptionDelayOperation()
      : super(fragment: CfApiConst.getRedemptionDelay);

  @override
  List input() {
    return []; // No input parameters required for this operation.
  }

  @override
  int onResponse(List result) {
    return (result[0] as BigInt)
        .toInt(); // Parsing the result to return as an integer.
  }
}

/// Abstract class for executing vault operations.
abstract class EvmVaultExcuteOperation extends EvmExcuteOperation {
  EvmVaultExcuteOperation({required AbiFunctionFragment fragment})
      : super(fragment: fragment);
}

/// Class for swapping tokens in a vault operation.
class EvmVaultXSwapTokenOperation extends EvmVaultExcuteOperation {
  /// The destination address and associated chain for the token swap.
  final AssetAndChainAddress destination;

  /// The contract address of the token being swapped.
  final ETHAddress tokenAddress;

  /// The amount of tokens to swap.
  final BigInt amount;

  final List<int> cfParameters;

  EvmVaultXSwapTokenOperation(
      {required this.destination,
      required this.tokenAddress,
      required this.amount,
      required List<int> cfParameters})
      : cfParameters =
            cfParameters.asImmutableBytes, // Ensures immutability of parameters
        super(
            fragment: CfApiConst
                .xSwapToken); // Calls the superclass constructor with the specific fragment for swapping tokens.

  @override
  List input({CfNetwork? network}) {
    return [
      BigInt.from(destination.chain.chain
          .getChainVariantId()), // Chain variant ID for the destination.
      destination.addressBytes(
          network: network), // Byte representation of the destination address.
      BigInt.from(destination.chain.chain.getAssetVariantId(destination
          .chain.asset)), // Asset variant ID for the asset being swapped.
      tokenAddress, // Byte representation of the token contract address.
      amount, // The amount of tokens to swap.
      cfParameters // Chain flip parameters.
    ];
  }
}

/// Class for swapping native tokens in a vault operation.
class EvmVaultXSwapNativeOperation extends EvmVaultExcuteOperation {
  /// The destination address and associated chain for the native swap.
  final AssetAndChainAddress destination;

  final List<int> cfParameters;

  EvmVaultXSwapNativeOperation(
      {required this.destination, List<int> cfParameters = const []})
      : cfParameters =
            cfParameters.asImmutableBytes, // Ensures immutability of parameters
        super(
            fragment: CfApiConst
                .xSwapNative); // Calls the superclass constructor with the specific fragment for swapping native tokens.

  @override
  List input({CfNetwork? network}) {
    return [
      BigInt.from(destination.chain.chain
          .getChainVariantId()), // Chain variant ID for the destination.
      destination.addressBytes(
          network: network), // Byte representation of the destination address.
      BigInt.from(destination.chain.chain.getAssetVariantId(destination
          .chain.asset)), // Asset variant ID for the asset being swapped.
      cfParameters // Chain flip parameters.
    ];
  }
}

/// Class for calling a native function in a vault operation.
class EvmVaultXCallNativeOperation extends EvmVaultExcuteOperation {
  /// The destination address and associated chain for the native call.
  final AssetAndChainAddress destination;

  final CfChannelMetadataParams metadata;

  EvmVaultXCallNativeOperation({
    required this.destination,
    required this.metadata,
  }) : super(
            fragment: CfApiConst
                .xCallNative); // Calls the superclass constructor with the specific fragment for calling native functions.

  @override
  List input({CfNetwork? network}) {
    return [
      BigInt.from(destination.chain.chain
          .getChainVariantId()), // Chain variant ID for the destination.
      destination.addressBytes(
          network: network), // Byte representation of the destination address.
      BigInt.from(destination.chain.chain.getAssetVariantId(
          destination.chain.asset)), // Asset variant ID for the asset involved.
      metadata.message, // The message to be sent with the call.
      metadata.gasBudget, // Gas budget for the transaction.
      metadata.cfParameters // Chain flip parameters.
    ];
  }
}

/// Class for calling a token function in a vault operation.
class EvmVaultXCallTokenOperation extends EvmVaultExcuteOperation {
  /// The destination address and associated chain for the token call.
  final AssetAndChainAddress destination;

  /// Metadata related to the channel for the operation.
  final CfChannelMetadataParams metadata;

  /// The amount of tokens to transfer with the call.
  final BigInt amount;

  /// The contract address of the source token.
  final ETHAddress srcToken;

  EvmVaultXCallTokenOperation(
      {required this.destination,
      required this.metadata,
      required this.amount,
      required this.srcToken})
      : super(
            fragment: CfApiConst
                .xCallToken); // Calls the superclass constructor with the specific fragment for calling token functions.

  @override
  List input({CfNetwork? network}) {
    return [
      BigInt.from(destination.chain.chain
          .getChainVariantId()), // Chain variant ID for the destination.
      destination.addressBytes(
          network: network), // Byte representation of the destination address.
      BigInt.from(destination.chain.chain.getAssetVariantId(
          destination.chain.asset)), // Asset variant ID for the asset involved.
      metadata.message, // The message to be sent with the call.
      metadata.gasBudget, // Gas budget for the transaction.
      srcToken, // token contract address.
      amount, // The amount of tokens to transfer with the call.
      metadata.cfParameters // Chain flip parameters.
    ];
  }
}
