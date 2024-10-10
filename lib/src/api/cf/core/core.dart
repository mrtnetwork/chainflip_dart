import 'package:chainflip_dart/src/provider/models/models/rpc.dart';
import 'package:chainflip_dart/src/api/cf/impl/substrate.dart';
import 'package:chainflip_dart/src/api/chains/chains/eth.dart';
import 'package:chainflip_dart/src/api/chains/chains/substrate.dart';
import 'package:chainflip_dart/src/types/types/chain_flip_networks.dart';
import 'package:chainflip_dart/src/api/cf/models/models.dart';
import 'package:chainflip_dart/src/api/cf/impl/eth.dart';
import 'package:chainflip_dart/src/api/cf/operations/evm.dart';
import 'package:chainflip_dart/src/api/cf/operations/substrate.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// Abstract core class for ChainFlip APIs.
abstract class CfApiCore {
  /// The network associated with the API.
  abstract final CfNetwork network;
}

/// Abstract class for ChainFlip EVM-related API functions.
abstract class CfEvmApiCore extends CfApiCore {
  /// Ethereum interaction API for EVM-based operations.
  abstract final EthereumIntractApi ethereumApi;

  /// Calls a Flip contract with a specified operation and RPC.
  Future<RESULT> callFlipContract<RESULT>({
    required EVMERC20ContractOperation<RESULT> operation,
    ETHAddress? flipContractAddress,
    ETHAddress? from,
  });

  /// Calls the State Chain Gateway contract with a specified operation and RPC.
  Future<RESULT> callStateChainGatewayContract<RESULT>({
    required EvmStateChainGatewayCallOperation<RESULT> operation,
    ETHAddress? stateChainGatewayAddress,
    ETHAddress? from,
  });

  /// Builds a transaction for the State Chain Gateway contract.
  Future<ETHTransactionBuilder> buildStateChainGatewayContractTransaction({
    required EvmStateChainGatewayExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    ETHAddress? stateChainGatewayAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  });

  /// Builds a transaction for a Vault contract.
  Future<ETHTransactionBuilder> buildVaultContractTransaction({
    required EvmVaultExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    VaultContractChain? vaultChain,
    ETHAddress? vaultContractAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  });

  /// Builds a transaction for a Flip contract.
  Future<ETHTransactionBuilder> buildFlipContractTransaction({
    required EVMERC20ContractExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    ETHAddress? flipContractAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  });
}

/// Abstract class for ChainFlip Substrate-related API functions.
abstract class CfSubstrateApiCore implements CfApiCore {
  /// Substrate interaction API for Substrate-based operations.
  abstract final SubstrateIntractApi substrateApi;

  /// Builds the payload for a Substrate operation.
  Future<BaseTransactionPayload> buildOperationPayload({
    required CfSubstrateOperation operation,
    required SubstrateAddress source,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  });

  /// Requests a swap deposit address for a ChainFlip operation.
  Future<BrokerRequestSwapDepositAddressResponse> requestSwapDepositAddress({
    required CfSubstrateRequestSwapDepositAddress operation,
    required SubstrateAddress? source,
    required SubstratePrivateKey signer,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  });

  /// Requests a liquidity deposit address for a ChainFlip operation.
  Future<LiquidityDepositAddressResponse> requestLiquidityDepositAddress({
    required CfSubstrateLiquidityDepositAddressOperation operation,
    required SubstrateAddress? source,
    required SubstratePrivateKey signer,
    String? genesisHash,
    String? blockHash,
    int? nonce,
  });
}

/// Combines EVM and Substrate API functionality for ChainFlip.
abstract class CfFullApiCore implements CfEthereumApiImpl, CfSubstrateApiCore {}

/// Substrate API implementation for ChainFlip.
class CfSubstrateApi extends CfSubstrateApiCore with SubstrateApiImpl {
  @override
  final SubstrateIntractApi substrateApi;
  @override
  final CfNetwork network;

  CfSubstrateApi({required this.substrateApi, required this.network});
}

/// EVM API implementation for ChainFlip.
class CfEvmApi extends CfEvmApiCore with CfEthereumApiImpl {
  @override
  final CfNetwork network;
  @override
  final EthereumIntractApi ethereumApi;

  CfEvmApi({required this.network, required this.ethereumApi});
}

/// Full API implementation for ChainFlip combining both EVM and Substrate.
class CfFullApi extends CfFullApiCore with SubstrateApiImpl, CfEthereumApiImpl {
  @override
  final CfNetwork network;
  @override
  final SubstrateIntractApi substrateApi;
  @override
  final EthereumIntractApi ethereumApi;

  CfFullApi(
      {required this.network,
      required this.substrateApi,
      required this.ethereumApi});
}
