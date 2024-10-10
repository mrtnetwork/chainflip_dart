import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/api/cf/operations/evm.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/api/cf/models/models.dart';
import 'package:on_chain/on_chain.dart';

class EthereumIntractApi {
  final EVMRPC provider;
  const EthereumIntractApi(this.provider);

  /// Builds an Ethereum transaction with specified parameters.
  Future<ETHTransactionBuilder> buildEthereumTransaction(
      {required ETHAddress from,
      required ETHAddress to,
      BigInt? chainId,
      List<int>? data,
      BigInt? nativeAmount,
      EVMTransactionParams? params}) async {
    chainId ??= await provider.request(RPCGetChainId());
    final transaction = ETHTransactionBuilder(
      from: from,
      to: to,
      value: nativeAmount ?? BigInt.zero,
      chainId: chainId!,
      memo: data == null ? null : BytesUtils.toHexString(data),
      transactionType: params?.transactionType,
    );
    params?.filledTransaction(transaction);
    await transaction.autoFill(
        provider, params?.feeRate ?? EIP1559FeeRate.normal);
    return transaction;
  }

  /// sign transaction
  Future<ETHTransactionBuilder> signTransaction(
      {required ETHTransactionBuilder transaction,
      required ETHPrivateKey signer}) async {
    transaction.sign(signer);
    return transaction;
  }

  /// send transaction to network
  Future<String> sendTransaction(ETHTransactionBuilder transaction) async {
    return transaction.sendTransaction(provider);
  }

  Future<TransactionReceipt> sendAndSubmitTransaction(
      ETHTransactionBuilder transaction) async {
    return transaction.sendAndSubmitTransaction(provider);
  }

  /// call contract
  Future<T> callContract<T>(
      {required AbiFunctionFragment function,
      required List<dynamic> input,
      required ETHAddress contractAddress,
      ETHAddress? from}) async {
    final call = await provider.request(RPCCall.fromMethod(
        contractAddress: contractAddress.address,
        function: function,
        params: input,
        from: from?.address));
    return call;
  }

  /// build contract transaction
  Future<ETHTransactionBuilder> buildContractTransaction({
    required AbiFunctionFragment function,
    required List<dynamic> functionInputs,
    required ETHAddress account,
    required ETHAddress contractAddress,
    EVMTransactionParams? params,
    BigInt? chainId,
    BigInt? nativeAmount,
  }) async {
    if (function.payable ?? false) {
      if (nativeAmount == null) {
        throw DartCfPluginException(
            "Payable contract: This operation requires a certain amount of native currency to execute.");
      }
    }
    chainId ??= await provider.request(RPCGetChainId());
    final data = function.encode(functionInputs);
    print(BytesUtils.toHexString(data));
    print("chain id ${chainId}");
    return buildEthereumTransaction(
        from: account,
        to: contractAddress,
        chainId: chainId!,
        data: data,
        nativeAmount: nativeAmount,
        params: params);
  }

  Future<ETHTransactionBuilder> buildErc20ContractOperation({
    required ETHAddress account,
    required ETHAddress contractAddress,
    required EVMERC20ContractExcuteOperation operation,
    BigInt? chainId,
  }) {
    return buildContractTransaction(
        function: operation.fragment,
        functionInputs: operation.input(),
        account: account,
        contractAddress: contractAddress,
        chainId: chainId);
  }

  Future<T> callErc20ContractOperation<T>(
      {required EVMERC20ContractOperation<T> operation,
      required ETHAddress contractAddress,
      ETHAddress? from}) async {
    final call = await provider.request(RPCCall.fromMethod(
        contractAddress: contractAddress.address,
        function: operation.fragment,
        params: operation.input(),
        from: from?.address));
    return operation.onResponse(call);
  }

  Future<BigInt> getAccountBalance(ETHAddress account) async {
    return await provider.request(RPCGetBalance(address: account.address));
  }
}
