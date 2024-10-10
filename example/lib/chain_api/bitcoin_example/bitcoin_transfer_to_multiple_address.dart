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

  /// owner address
  final p2pkh = privateKey.getPublic().toAddress();

  final p2shP2pk = BitcoinAddress("2NG25NBHKGa76qKAcmhFv5pJ8H8yEXLyKrN",
      network: bitcoinNetwok);
  final p2shP2wpkh = BitcoinAddress("2NDJACB9Pn5GHGt7CUBFka7SryjbUDu6d3r",
      network: bitcoinNetwok);
  final p2wpkh = BitcoinAddress("tb1qw6hrrn3wmwqg2sx37npy62rjds70j9mf8spccq",
      network: bitcoinNetwok);
  final p2tr = BitcoinAddress(
      "tb1pg5u7lxwju4l7sxspzt26x92mn0s90v3ypx2qhy6tt9ga5lxher8qrdj59k",
      network: bitcoinNetwok);
  final api = BitcoinIntractApi(network: bitcoinNetwok, provider: provider);
  final utxos = await api.fetchUtxos([
    BitcoinSpenderInfo(
        address: BitcoinAddress.fromBaseAddress(p2pkh, network: bitcoinNetwok),
        publicKey: privateKey.getPublic().toHex()),
  ]);
  final transaction = await api.buildTransaction(
      utxos: utxos,
      outputs: [
        BitcoinOutput(
            address: p2shP2pk.baseAddress,
            value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: p2shP2wpkh.baseAddress,
            value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: p2wpkh.baseAddress, value: BtcUtils.toSatoshi("0.00001")),
        BitcoinOutput(
            address: p2tr.baseAddress, value: BtcUtils.toSatoshi("0.00001"))
      ],
      changeAddress:
          BitcoinAddress.fromBaseAddress(p2pkh, network: bitcoinNetwok),
      feeRate: BigInt.two);
  final signedTransaction = await api
      .signTransaction(transaction: transaction, signers: [privateKey]);
  await api.submitTransaction(signedTransaction);

  /// https://mempool.space/testnet/tx/683cac98659f7f6069c7f44198de9cd9a015f147808f8e23d39fe16dd0aeb5e7
}
