import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/api/chains/chains/eth.dart';
import 'package:chainflip_dart/src/types/types/chain_flip_networks.dart';
import 'package:chainflip_dart/src/api/cf/core/core.dart';
import 'package:chainflip_dart/src/api/cf/models/models.dart';
import 'package:chainflip_dart/src/api/cf/operations/evm.dart';
import 'package:on_chain/on_chain.dart';

/// Mixin implementation for ChainFlip Ethereum API operations.
mixin CfEthereumApiImpl on CfEvmApiCore {
  /// Gets the network for the ChainFlip API.
  CfNetwork get network;

  /// Gets the Ethereum interaction API.
  EthereumIntractApi get ethereumApi;

  /// Calls the Flip contract with a specified operation and RPC.
  Future<RESULT> callFlipContract<RESULT>({
    required EVMERC20ContractOperation<RESULT> operation,
    ETHAddress? flipContractAddress,
    ETHAddress? from,
  }) async {
    final call = await ethereumApi.callContract(
      function: operation.fragment,
      input: operation.input(),
      contractAddress:
          flipContractAddress ?? ETHAddress(network.flipContractAddress),
      from: from,
    );
    return operation.onResponse(call);
  }

  /// Calls the State Chain Gateway contract with a specified operation and RPC.
  Future<RESULT> callStateChainGatewayContract<RESULT>({
    required EvmStateChainGatewayCallOperation<RESULT> operation,
    ETHAddress? stateChainGatewayAddress,
    ETHAddress? from,
  }) async {
    final call = await ethereumApi.callContract(
      function: operation.fragment,
      input: operation.input(),
      contractAddress: stateChainGatewayAddress ??
          ETHAddress(network.stateChainGatewayAddress),
      from: from,
    );
    return operation.onResponse(call);
  }

  /// Builds a transaction for the State Chain Gateway contract.
  Future<ETHTransactionBuilder> buildStateChainGatewayContractTransaction({
    required EvmStateChainGatewayExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    ETHAddress? stateChainGatewayAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  }) async {
    return ethereumApi.buildContractTransaction(
      function: operation.fragment,
      functionInputs: operation.input(network: network),
      contractAddress: stateChainGatewayAddress ??
          ETHAddress(network.stateChainGatewayAddress),
      chainId: chainId ?? network.stateChainId,
      account: account,
      nativeAmount: nativeAmount,
      params: params,
    );
  }

  /// Builds a transaction for a Vault contract.
  Future<ETHTransactionBuilder> buildVaultContractTransaction({
    required EvmVaultExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    VaultContractChain? vaultChain,
    ETHAddress? vaultContractAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  }) async {
    if ((chainId != null && vaultContractAddress == null) ||
        (chainId == null && vaultContractAddress != null)) {
      throw DartCfPluginException(
          "Use both `chainId` and `vaultContractAddress` to detect the current contract's chain, or use `vaultChain` for detection.");
    }
    if (chainId == null || vaultContractAddress == null) {
      if (vaultChain == null) {
        throw DartCfPluginException(
            "Use both `chainId` and `vaultContractAddress` to detect the current contract's chain, or use `vaultChain` for detection.");
      }
      chainId = network.vaultChainId(vaultChain);
      vaultContractAddress =
          ETHAddress(network.getValueContractAddress(vaultChain));
    }
    return ethereumApi.buildContractTransaction(
        function: operation.fragment,
        functionInputs: operation.input(network: network),
        contractAddress: vaultContractAddress,
        chainId: chainId,
        account: account,
        nativeAmount: nativeAmount,
        params: params);
  }

  /// Builds a transaction for a Flip contract.
  Future<ETHTransactionBuilder> buildFlipContractTransaction({
    required EVMERC20ContractExcuteOperation operation,
    required ETHAddress account,
    EVMTransactionParams? params,
    ETHAddress? flipContractAddress,
    BigInt? chainId,
    BigInt? nativeAmount,
  }) async {
    return ethereumApi.buildContractTransaction(
      function: operation.fragment,
      functionInputs: operation.input(network: network),
      contractAddress:
          flipContractAddress ?? ETHAddress(network.flipContractAddress),
      chainId: chainId ?? network.stateChainId,
      account: account,
      nativeAmount: nativeAmount,
      params: params,
    );
  }

  Future<BigInt> getFlipBalance({
    required ETHAddress address,
    ETHAddress? flipContractAddress,
  }) {
    return ethereumApi.callErc20ContractOperation(
        operation: EvmGetTokenBalanceOperation(address),
        contractAddress:
            flipContractAddress ?? ETHAddress(network.flipContractAddress));
  }
}
