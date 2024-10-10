import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/services/electrum/electrum_ssl_service.dart';

void main() async {
  const bitcoinNetwok = BitcoinNetwork.testnet;
  final service =
      await ElectrumSSLService.connect("testnet.aranguren.org:51002");
  final provider = ElectrumApiProvider(service);

  final seed = List<int>.filled(32, 25);
  final hdWallet = Bip44.fromSeed(seed, Bip44Coins.bitcoin).deriveDefaultPath;
  final privateKey = ECPrivate.fromBytes(hdWallet.privateKey.raw);

  /// create 5 spender from same private key
  /// you can also generate aaddress from another private key and spend in same transaction
  final p2pkh = privateKey.getPublic().toAddress();

  /// It's crucial to know the correct P2SH type when spending from a P2SH address.
  /// For example, when creating an address from a public key, the correct P2SH type
  /// is automatically determined. However, if you instantiate a P2SH address directly,
  /// like BitcoinAddress("2MudzFnNxFuE652UV4cRNZUjMuvmQUsUBXM", network: bitcoinNetwork),
  /// the P2SH type will default to P2SH-P2PK (Pay-to-Script-Hash Pay-to-PubKey).
  /// In this case, the account type will always be P2SH-P2PK, which may result in an
  /// incorrect output script and cause transaction submission to fail.
  /// if you known the correct type you can use  BitcoinAddress.fromBaseAddress(P2shAddress.fromAddress(address: "2NECEUra7eXLbGabXHsFZoimpV7a4Hv8BYa",network: bitcoinNetwok, type: P2shAddressType.p2wpkhInP2sh),network: bitcoinNetwok)
  /// Note: The specific P2SH type is only relevant when spending, not when creating output scripts.
  final p2shP2pk = privateKey.getPublic().toP2pkInP2sh();
  final p2shP2wpkh = privateKey.getPublic().toP2wpkhInP2sh();

  final p2wpkh = privateKey.getPublic().toSegwitAddress();
  final p2tr = privateKey.getPublic().toTaprootAddress();

  final output1 = BitcoinAddress("2MudzFnNxFuE652UV4cRNZUjMuvmQUsUBXM",
      network: bitcoinNetwok);
  final output2 = BitcoinAddress("2NECEUra7eXLbGabXHsFZoimpV7a4Hv8BYa",
      network: bitcoinNetwok);
  final output3 = BitcoinAddress("tb1qyqd6348yls5kn6tuzhv47qm7xl8nczexpj525d",
      network: bitcoinNetwok);
  final output4 = BitcoinAddress(
      "tb1p5ejqc36gxlu2hgz5x5rsq6wc4xg9jk87tjwf5x39h4arwlay9upscv2qwq",
      network: bitcoinNetwok);
  final api = BitcoinIntractApi(network: bitcoinNetwok, provider: provider);
  final utxos = await api.fetchUtxos([
    BitcoinSpenderInfo(
        address: BitcoinAddress.fromBaseAddress(p2pkh, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
    BitcoinSpenderInfo(
        address:
            BitcoinAddress.fromBaseAddress(p2shP2pk, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
    BitcoinSpenderInfo(
        address:
            BitcoinAddress.fromBaseAddress(p2shP2wpkh, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
    BitcoinSpenderInfo(
        address: BitcoinAddress.fromBaseAddress(p2wpkh, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
    BitcoinSpenderInfo(
        address: BitcoinAddress.fromBaseAddress(p2tr, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
  ]);
  final transaction = await api.buildTransaction(
      utxos: utxos,
      outputs: [
        BitcoinOutput(
            address: output1.baseAddress, value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: output2.baseAddress, value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: output3.baseAddress, value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: output4.baseAddress, value: BtcUtils.toSatoshi("0.00001"))
      ],
      changeAddress:
          BitcoinAddress.fromBaseAddress(p2pkh, network: bitcoinNetwok),
      feeRate: BigInt.two);
  final signedTransaction = await api
      .signTransaction(transaction: transaction, signers: [privateKey]);
  signedTransaction.txId();

  await api.submitTransaction(signedTransaction);

  /// https://mempool.space/testnet/tx/c113a7f008a7802d665208847b2c5e17e41563dfbe7da6d527e07a5c6593f249
}
