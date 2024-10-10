import 'dart:async';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/api/cf/api.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateIntractApi {
  final MetadataApi api;
  final SubstrateRPC provider;
  const SubstrateIntractApi({required this.api, required this.provider});

  static Future<SubstrateIntractApi> atRuntimeMetadata(
      SubstrateRPC provider) async {
    final metadata =
        await provider.request(SubstrateRPCRuntimeMetadataGetMetadata());
    return SubstrateIntractApi(api: metadata!.toApi(), provider: provider);
  }

  /// Builds the subtract call data from metadata using the provided inputs and pallet name.
  List<int> buildCallBytes(
      {required String palletName,
      required Map<String, dynamic> inputs,
      bool inputGeneratedByTemplate = false}) {
    try {
      api.getCallLookupId(palletName);
    } catch (e) {
      throw DartCfPluginException(
          "The provided Substrate metadata does not support the pallet: $palletName.");
    }
    return api.encodeCall(
        palletNameOrIndex: palletName,
        value: inputs,
        fromTemplate: inputGeneratedByTemplate);
  }

  /// Builds the call bytes for transferring a native amount.
  /// ChainFlip does not support this instruction, but it is useful for
  /// transferring from the Polkadot or Kusama network.
  List<int> builTransferCallBytes(
      {required SubstrateAddress destination, required BigInt amount}) {
    final template = {
      "type": "Enum",
      "key": "transfer_allow_death",
      "value": {
        "value": {
          "dest": {
            "key": "Id",
            "value": {"value": destination.toBytes()},
          },
          "value": {"value": amount}
        }
      },
    };
    return buildCallBytes(
        inputs: template,
        palletName: "balances",
        inputGeneratedByTemplate: true);
  }

  /// get account nonce
  Future<int> getAccountNonce(SubstrateAddress source) async {
    final data = await api.getStorage(
        request: QueryStorageRequest<Map<String, dynamic>>(
            palletNameOrIndex: "System",
            methodName: "account",
            input: source.toBytes(),
            identifier: 0),
        rpc: provider,
        fromTemplate: false);
    return data.result["nonce"];
  }

  /// build and filled substrate transaction
  Future<BaseTransactionPayload> buildTransaction(
      {required List<int> callBytes,
      required SubstrateAddress source,
      String? genesisHash,
      String? blockHash,
      int? nonce}) async {
    final version = api.runtimeVersion();
    genesisHash ??= await provider
        .request(const SubstrateRPCChainGetBlockHash<String>(number: 0));
    nonce ??= await getAccountNonce(source);
    blockHash ??=
        await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
    final blockHeader = await provider
        .request(SubstrateRPCChainChainGetHeader(atBlockHash: blockHash));
    final era = blockHeader.toMortalEra();
    if (api.metadata.isSupportMetadataHash) {
      return TransactionPayload(
          blockHash: SubstrateBlockHash.hash(blockHash!),
          era: era,
          genesisHash: SubstrateBlockHash.hash(genesisHash!),
          method: callBytes,
          nonce: nonce,
          specVersion: version.specVersion,
          transactionVersion: version.transactionVersion,
          tip: BigInt.zero);
    }
    return LegacyTransactionPayload(
        blockHash: SubstrateBlockHash.hash(blockHash!),
        era: era,
        genesisHash: SubstrateBlockHash.hash(genesisHash!),
        method: callBytes,
        nonce: nonce,
        specVersion: version.specVersion,
        transactionVersion: version.transactionVersion,
        tip: BigInt.zero);
  }

  /// send transaction to network
  Future<String> submitTransaction(
      {required SubstrateRPC provider, required Extrinsic extrinsic}) async {
    return await provider.request(
        SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
  }

  Stream<SubtrateTransactionSubmitionResult> _findTransactionStream(
      {Duration retryInterval = const Duration(seconds: 4),
      required int blockId,
      required String extrinsic,
      required String transactionHash,
      int maxRetryEachBlock = 5,
      int blockCount = 20}) {
    final controller = StreamController<SubtrateTransactionSubmitionResult>();
    void closeController() {
      if (!controller.isClosed) {
        controller.close();
      }
    }

    void startFetching() async {
      int id = blockId;
      int retry = maxRetryEachBlock;
      int count = blockCount;
      while (!controller.isClosed) {
        try {
          final result = await _lockupBlock(
              blockId: id,
              extrinsic: extrinsic,
              transactionHash: transactionHash);
          id++;
          count--;
          retry = maxRetryEachBlock;
          if (result != null) {
            controller.add(result);
            closeController();
          } else if (count <= 0) {
            controller.addError(DartCfPluginException(
                "Failed to fetch the block within the last ${blockCount} blocks."));
            closeController();
          }
        } on DartCfPluginException catch (e) {
          controller.addError(e);
          controller.close();
        } catch (_) {
          retry--;
          if (retry <= 0) {
            controller.addError(DartCfPluginException(
                "Failed to fetch the transaction within the allotted time."));
            closeController();
          }
        }
        await Future.delayed(retryInterval);
      }
    }

    startFetching();
    return controller.stream.asBroadcastStream(onCancel: (e) {
      controller.close();
    });
  }

  /// Sends a transaction and waits for it to be included in a block,
  /// retrieving the events related to the transaction.
  Future<SubtrateTransactionSubmitionResult> submitExtrinsicAndWatch(
      {required Extrinsic extrinsic, int maxRetryEachBlock = 5}) async {
    final blockHeader =
        await provider.request(SubstrateRPCChainChainGetHeader());
    final ext = extrinsic.toHex(prefix: "0x");
    final transactionHash =
        await provider.request(SubstrateRPCAuthorSubmitExtrinsic(ext));
    final completer = Completer<SubtrateTransactionSubmitionResult>();
    StreamSubscription<SubtrateTransactionSubmitionResult>? stream;
    try {
      stream = _findTransactionStream(
              blockId: blockHeader.number,
              extrinsic: ext,
              maxRetryEachBlock: maxRetryEachBlock,
              transactionHash: transactionHash)
          .listen(
              (e) async {
                completer.complete(e);
              },
              onDone: () {},
              onError: (e) {
                if (completer.isCompleted) return;
                if (e is DartCfPluginException) {
                  completer.completeError(DartCfPluginException(e.message,
                      details: {"tx": transactionHash, ...e.details ?? {}}));
                } else {
                  completer.completeError(DartCfPluginException(
                      "Failed to fetch the transaction. $transactionHash",
                      details: {"tx": transactionHash, "stack": e.toString()}));
                }
              });
      return await completer.future;
    } finally {
      stream?.cancel();
      stream = null;
    }
  }

  Future<SubtrateTransactionSubmitionResult?> _lockupBlock(
      {required int blockId,
      required String extrinsic,
      required String transactionHash}) async {
    final blockHash = await provider
        .request(SubstrateRPCChainGetBlockHash<String?>(number: blockId));
    if (blockHash == null) {
      throw TypeError();
    }
    try {
      final block = await provider
          .request(SubstrateRPCChainGetBlock(atBlockHash: blockHash));
      final index = block.block.extrinsics.indexOf(extrinsic);
      if (index < 0) return null;
      final events =
          await api.getSystemEvents(provider, atBlockHash: blockHash);
      return SubtrateTransactionSubmitionResult(
          events: events.where((e) => e.applyExtrinsic == index).toList(),
          block: blockHash,
          extrinsic: extrinsic,
          blockNumber: blockId,
          transactionHash: transactionHash);
    } catch (e) {
      throw DartCfPluginException("Somthing wrong when parsing block",
          details: {"block": blockHash, "stack": e.toString()});
    }
  }

  /// sign transaction
  Extrinsic signTransaction(
      {required BaseTransactionPayload payload,
      required SubstratePrivateKey signer}) {
    final multiSignature = signer.multiSignature(payload.serialzeSign());
    final signature = payload.toExtrinsicSignature(
        signature: multiSignature, signer: signer.toAddress());
    return Extrinsic(signature: signature, methodBytes: payload.method);
  }
}
