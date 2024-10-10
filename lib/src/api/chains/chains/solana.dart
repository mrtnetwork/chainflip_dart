import 'package:blockchain_utils/bip/ecc/keys/ed25519_keys.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:chainflip_dart/src/api/chains/types/types.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:on_chain/on_chain.dart';

class SolanaTransactionParams {
  final SolAddress? recentBlockhash;
  final TransactionType type;
  final List<AddressLookupTableAccount>? addressLookupTableAccounts;
  final SolAddress payer;
  SolanaTransactionParams._({
    required this.recentBlockhash,
    required this.type,
    List<AddressLookupTableAccount>? addressLookupTableAccounts,
    required this.payer,
  }) : addressLookupTableAccounts = addressLookupTableAccounts?.immutable;
  factory SolanaTransactionParams.v0(
      {required SolAddress payer,
      SolAddress? recentBlockhash,
      List<AddressLookupTableAccount>? addressLookupTableAccounts}) {
    return SolanaTransactionParams._(
        recentBlockhash: recentBlockhash,
        type: TransactionType.v0,
        payer: payer,
        addressLookupTableAccounts: addressLookupTableAccounts);
  }
  factory SolanaTransactionParams.lagacy({
    required SolAddress payer,
    SolAddress? recentBlockhash,
  }) {
    return SolanaTransactionParams._(
        recentBlockhash: recentBlockhash,
        type: TransactionType.legacy,
        payer: payer);
  }
}

class SolanaIntractApi {
  final SolanaRPC provider;
  const SolanaIntractApi(this.provider);

  /// send transaction to network
  Future<String> submitTransaction({
    required SolanaTransaction transaction,
    bool verifySignatures = true,
    Commitment? commitment = Commitment.finalized,
    bool skipPreflight = false,
    int? maxRetries,
    MinContextSlot? minContextSlot,
  }) async {
    final serializedTransaction =
        transaction.serializeString(verifySignatures: verifySignatures);
    return await provider.request(SolanaRPCSendTransaction(
        encodedTransaction: serializedTransaction,
        commitment: commitment,
        maxRetries: maxRetries,
        skipPreflight: skipPreflight,
        minContextSlot: minContextSlot));
  }

  /// sign transaction
  Future<SolanaTransaction> signTransaction(
      {required SolanaTransaction transaction,
      required List<SolanaPrivateKey> signers}) async {
    transaction.sign(signers);
    return transaction;
  }

  /// build solana transaction
  Future<SolanaTransaction> buildTransaction(
      {required List<TransactionInstruction> instructions,
      required SolanaTransactionParams params}) async {
    SolAddress? recentBlockhash = params.recentBlockhash;
    if (recentBlockhash == null) {
      final blockHash =
          await provider.request(const SolanaRPCGetLatestBlockhash());
      recentBlockhash = blockHash.blockhash;
    }
    return SolanaTransaction(
        payerKey: params.payer,
        instructions: instructions,
        recentBlockhash: recentBlockhash);
  }

  /// create transaction instruction for transafer sol
  Future<TransactionInstruction> buildTransferInstruction(
      {required BigInt lamports,
      required SolAddress source,
      required SolAddress destination,
      bool verifySourceIsUninitializedOrOwnedBySystemProgram = true}) async {
    if (verifySourceIsUninitializedOrOwnedBySystemProgram) {
      final destinationInfo =
          await provider.request(SolanaRPCGetAccountInfo(account: destination));
      if (destinationInfo != null &&
          destinationInfo.owner != SystemProgramConst.programId) {
        throw DartCfPluginException(
            "Destination account is not owned by the System Program. Please verify the address or disable the `verifySourceIsUninitializedOrOwnedBySystemProgram` option.");
      }
    }
    return SystemProgram.transfer(
        layout: SystemTransferLayout(lamports: lamports),
        from: source,
        to: destination);
  }

  /// create AssociatedTokenAccount instruction
  Future<TransactionInstruction> buildAssociatedTokenAccountInstruction(
      {required BigInt lamports,
      required SolAddress owner,
      required SolAddress mintAccount,
      required SolAddress payer,
      SolAddress tokenProgramId = SPLTokenProgramConst.tokenProgramId}) async {
    final associatedTokenAccount =
        AssociatedTokenAccountProgramUtils.associatedTokenAccount(
            mint: mintAccount, owner: owner, tokenProgramId: tokenProgramId);
    return AssociatedTokenAccountProgram.associatedTokenAccount(
        payer: payer,
        associatedToken: associatedTokenAccount.address,
        owner: owner,
        mint: mintAccount,
        tokenProgramId: tokenProgramId);
  }

  /// create account instruction
  Future<TransactionInstruction> createAccountInstruction({
    BigInt? rentAmount,
    required int space,
    required SolAddress from,
    required SolAddress newAccountPubKey,
    required SolAddress payer,
    required SolanaRPC rpc,
    SolAddress programId = SPLTokenProgramConst.tokenProgramId,
  }) async {
    BigInt lamportsRent = rentAmount ?? BigInt.zero;
    if (rentAmount == null) {
      final rent = await rpc
          .request(SolanaRPCGetMinimumBalanceForRentExemption(size: space));
      lamportsRent = rent;
    }
    return SystemProgram.createAccount(
        from: from,
        newAccountPubKey: newAccountPubKey,
        layout: SystemCreateLayout(
            lamports: lamportsRent,
            space: BigInt.from(space),
            programId: SPLTokenProgramConst.tokenProgramId));
  }

  /// Builds a transfer token instruction.
  /// The destination and owner must be public key accounts, not PDA addresses
  Future<List<TransactionInstruction>> buildTransferToken(
      {required SolAddress destination,
      required SolAddress mintAddress,
      required SolAddress owner,
      required BigInt tokenAmount,
      int? asTransferCheckDecimal,
      SolAddress? tokenProgramId}) async {
    if (!Ed25519PublicKey.isValidBytes(destination.toBytes())) {
      throw DartCfPluginException(
          "Invalid Solana public key provided. Please avoid using a PDA (Program Derived Address) as the destination address.");
    }
    if (!Ed25519PublicKey.isValidBytes(owner.toBytes())) {
      throw DartCfPluginException(
          "Invalid Solana public key provided. Please avoid using a PDA (Program Derived Address) as the source address.");
    }
    final destinationPdaInfo = await getTokenAccountAddress(
        account: destination,
        mint: mintAddress,
        tokenProgramId: tokenProgramId);
    final ownerPda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mintAddress,
        owner: owner,
        tokenProgramId: destinationPdaInfo.tokenProgramId);
    final destinationInfo = await provider.request(
        SolanaRPCGetAccountInfo(account: destinationPdaInfo.pdaAddress));
    TransactionInstruction? ascAccout;
    if (destinationInfo == null) {
      ascAccout = AssociatedTokenAccountProgram.associatedTokenAccount(
          payer: owner,
          associatedToken: destinationPdaInfo.pdaAddress,
          owner: destination,
          mint: mintAddress,
          tokenProgramId: destinationPdaInfo.tokenProgramId);
    }
    TransactionInstruction transfer;
    if (asTransferCheckDecimal != null) {
      transfer = SPLTokenProgram.transferChecked(
          layout: SPLTokenTransferCheckedLayout(
              amount: tokenAmount, decimals: asTransferCheckDecimal),
          owner: owner,
          mint: mintAddress,
          source: ownerPda.address,
          programId: destinationPdaInfo.tokenProgramId,
          destination: destinationPdaInfo.pdaAddress);
    } else {
      transfer = SPLTokenProgram.transfer(
          layout: SPLTokenTransferLayout(amount: tokenAmount),
          owner: owner,
          source: ownerPda.address,
          programId: destinationPdaInfo.tokenProgramId,
          destination: destinationPdaInfo.pdaAddress);
    }
    return [if (ascAccout != null) ascAccout, transfer];
  }

  Future<SolanaTokenPDAInfo> getTokenAccountAddress(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId}) async {
    if (tokenProgramId == null) {
      final mintAccount = await getAccount(mint);
      tokenProgramId = mintAccount.owner;
      if (tokenProgramId != SPLTokenProgramConst.token2022ProgramId &&
          tokenProgramId != SPLTokenProgramConst.tokenProgramId) {
        throw DartCfPluginException("Invalid mint account owner.",
            details: {"owner": tokenProgramId.address, "mint": mint.address});
      }
    }
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint, owner: account, tokenProgramId: tokenProgramId);
    return SolanaTokenPDAInfo(
        address: account,
        pdaAddress: pda.address,
        tokenProgramId: tokenProgramId);
  }

  Future<BigInt> getAccountBalance({required SolAddress address}) {
    return provider.request(SolanaRPCGetBalance(account: address));
  }

  Future<SolanaMintAccount> getMintAccount(SolAddress mint) async {
    final mintAccount =
        await provider.request(SolanaRPCGetMintAccount(account: mint));
    if (mintAccount == null) {
      throw DartCfPluginException("Mint account does not exists");
    }
    return mintAccount;
  }

  Future<SolanaAccountInfo> getAccount(SolAddress account) async {
    final mintAccount =
        await provider.request(SolanaRPCGetAccountInfo(account: account));
    if (mintAccount == null) {
      throw DartCfPluginException("Account does not exists.");
    }
    return mintAccount;
  }

  Future<SolanaTokenAccount> getTokenAccountInfo(
      {required SolAddress owner,
      required SolAddress mint,
      required SolanaRPC provider,
      SolAddress? tokenProgramId}) async {
    final account = await getTokenAccountAddress(
        account: owner, mint: mint, tokenProgramId: tokenProgramId);
    final tokenAccount = await provider
        .request(SolanaRPCGetTokenAccount(account: account.pdaAddress));
    if (tokenAccount == null) {
      throw DartCfPluginException("Token account does not exists.");
    }
    return tokenAccount;
  }
}
