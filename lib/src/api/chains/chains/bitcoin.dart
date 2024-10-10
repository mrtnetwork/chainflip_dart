import 'dart:ffi';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:chainflip_dart/src/exception/exception.dart';

/// Class for fetching account UTXOs.
/// Address of the spender.
/// Public key related to the address, used to identify UTXO signer when signing the transaction.
class BitcoinSpenderInfo {
  /// Spender address for fetching UTXOs.
  /// Important for P2SH addresses.
  /// When spending from a P2SH address, ensure you set the correct P2SH type.
  /// Incorrect type will cause transaction failure.
  final BitcoinAddress address;

  /// Public key related to the address, used to identify UTXO signer when signing the transaction.
  final String publicKey;
  const BitcoinSpenderInfo._({required this.publicKey, required this.address});
  factory BitcoinSpenderInfo(
      {required BitcoinAddress address, required String publicKey}) {
    return BitcoinSpenderInfo._(
        publicKey: ECPublic.fromHex(publicKey).toHex(compressed: true),
        address: address);
  }

  /// Public key hash useful for Electrum API to fetch address UTXOs.
  String get pubkeyHash => address.baseAddress.pubKeyHash();
}

/// Bitcoin interaction API.
/// Create, build, sign, and spend from P2PK, P2PKH, P2SH, P2WSH, P2WPH, and P2TR addresses.
class BitcoinIntractApi {
  /// The network to interact with (Testnet, Mainnet).
  final BitcoinNetwork network;
  final ElectrumApiProvider provider;
  const BitcoinIntractApi({required this.network, required this.provider});

  /// Fetches UTXOs for the given list of spender sources.
  Future<List<UtxoWithAddress>> fetchUtxos(
      List<BitcoinSpenderInfo> sources) async {
    final List<UtxoWithAddress> accountsUtxos = []; // List to hold UTXOs.
    for (final i in sources) {
      final elctrumUtxos = await provider.request(ElectrumScriptHashListUnspent(
          scriptHash: i.pubkeyHash)); // Request UTXOs from Electrum.
      final List<UtxoWithAddress> utxos = elctrumUtxos
          .map((e) => UtxoWithAddress(
              utxo: e.toUtxo(i.address.type), // Convert to UTXO format.
              ownerDetails: UtxoAddressDetails(
                  publicKey: i.publicKey,
                  address: i.address.baseAddress))) // Store owner details.
          .toList(); // Convert to list.
      accountsUtxos.addAll(utxos); // Add UTXOs to the main list.
    }
    return accountsUtxos; // Return all fetched UTXOs.
  }

  /// Builds a Bitcoin transaction with the specified UTXOs and outputs.
  Future<BitcoinTransactionBuilder> buildTransaction({
    /// List of UTXOs to spend.
    required List<UtxoWithAddress> utxos,

    /// Outputs to include in the transaction.
    required List<BitcoinOutput> outputs,

    /// Address for change outputs.
    required BitcoinAddress changeAddress,

    /// satoshis per virtual byte
    BigInt? feeRate,

    /// Input ordering strategy.
    BitcoinOrdering inputOrdering = BitcoinOrdering.bip69,

    /// Output ordering strategy.
    BitcoinOrdering outputOrdering = BitcoinOrdering.bip69,

    /// Enable Replace-By-Fee (RBF) if true.
    bool enableRBF = false,

    /// Optional OP_RETURN data for the transaction.
    List<int>? opReturn,
  }) async {
    List<BitcoinOutput> outs =
        List<BitcoinOutput>.from(outputs); // Create a mutable list of outputs.
    final sumOfUtxo = utxos.sumOfUtxosValue(); // Calculate total UTXO value.

    if (sumOfUtxo <= BigInt.zero) {
      throw DartCfPluginException(
          "No UTXOs found for spending"); // Check for UTXO availability.
    }

    if (feeRate != null && feeRate <= BigInt.zero) {
      throw DartCfPluginException(
          "FeeRate should not be zero or negative. You may also set the feeRate field to null to allow automatic fee calculation."); // Validate fee value.
    }

    BigInt sumOfOutputs = outs.fold<BigInt>(
        BigInt.zero,
        (previousValue, element) =>
            previousValue + element.value); // Sum output values.

    if (feeRate == null) {
      final networkEstimate = await provider.request(ElectrumEstimateFee(
          numberOfBlock: 15)); // Fetch fee estimate from provider.
      if (networkEstimate == null) {
        throw DartRepresentationOf(
            "the daemon does not have enough information to make an estimate");
      }
      feeRate = networkEstimate ~/ BigInt.from(1000);
    }
    int transactionSize = BitcoinTransactionBuilder.estimateTransactionSize(
        utxos: utxos, // Estimate transaction size.
        outputs: [
          ...outs,
          BitcoinOutput(address: changeAddress.baseAddress, value: BigInt.zero)
        ],
        network: network,
        memo: BytesUtils.tryToHexString(opReturn),
        enableRBF: enableRBF);
    final fee = BigInt.from(transactionSize) * feeRate;
    final changeValue =
        sumOfUtxo - (sumOfOutputs + fee); // Calculate change value.

    if (changeValue.isNegative) {
      throw DartCfPluginException(
          "The sum of the provided outputs in satoshis plus the fee exceeds the UTXO balance."); // Check if change is negative.
    } else if (changeValue > BigInt.zero) {
      outs.add(BitcoinOutput(
          address: changeAddress.baseAddress,
          value: changeValue)); // Add change output if applicable.
    }

    return BitcoinTransactionBuilder(
        outPuts: outs,
        fee: fee,
        network: network,
        utxos: utxos,
        memo: BytesUtils.tryToHexString(opReturn),
        inputOrdering: inputOrdering,
        outputOrdering: outputOrdering,
        enableRBF: enableRBF);
  }

  /// Signs a Bitcoin transaction using the provided private keys.
  /// For signing P2TR(Taproot script), you must use your own transaction builder
  Future<BtcTransaction> signTransaction({
    required BitcoinTransactionBuilder transaction, // Transaction to sign.
    required List<ECPrivate> signers, // List of private keys for signing.
  }) async {
    return transaction.buildTransaction(
      (trDigest, utxo, publicKey, sighash) {
        // Callback for transaction signing.
        final signer = signers.firstWhere(
            (e) =>
                e.getPublic().toHex() ==
                publicKey, // Find signer corresponding to public key.
            orElse: () => throw DartCfPluginException(
                "Signer key not found for the provided public key in the UTXO.")); // Error if signer not found.

        if (utxo.utxo.isP2tr()) {
          // Check if UTXO is Taproot.
          return signer.signTapRoot(trDigest,
              sighash: sighash); // Sign using Taproot method.
        }
        return signer.signInput(trDigest,
            sigHash: sighash); // Sign input for non-Taproot UTXOs.
      },
    );
  }

  /// send transaction to the network
  Future<String> submitTransaction(BtcTransaction transaction) async {
    return provider.request(
        ElectrumBroadCastTransaction(transactionRaw: transaction.serialize()));
  }
}
