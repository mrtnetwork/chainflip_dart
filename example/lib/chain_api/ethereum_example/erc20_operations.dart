// ignore_for_file: avoid_print

import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/ethereum_service_example.dart';

void main() async {
  final provier =
      EVMRPC(EthereumHttpService("https://rpc-amoy.polygon.technology/"));
  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
  final ethPrivateKey = ETHPrivateKey.fromBytes(hdWallet.privateKey.raw);

  final address = ethPrivateKey.publicKey().toAddress();
  final api = EthereumIntractApi(provier);
  final balance = await api.callErc20ContractOperation(
      from: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmGetTokenBalanceOperation(
          ETHAddress("0xDdEDf30f96E6e2674Fab476bfC36201074081bcC")));

  print(balance);
  final tokenName = await api.callErc20ContractOperation(
      from: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmGetTokenNameOperation());
  print(tokenName);
  final symbol = await api.callErc20ContractOperation(
      from: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmGetTokenSymbolOperation());
  print(symbol);
  final decimals = await api.callErc20ContractOperation(
      from: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmGetTokenDecimalsOperation());
  print(decimals);
  final eip712Domain = await api.callErc20ContractOperation(
      from: address,
      contractAddress: ETHAddress("0xaC2DA80f46c37242B4a3892Ff979BfE7cA3B1d27"),
      operation: EvmGetEIP712DomainOperation());
  print(eip712Domain.verifyingContract);
}

/// https://www.oklink.com/amoy/tx/0x0f2799c4f38aa05f7a55e2bda61411711dea00571bdf637c59f02c4f879cd31f
