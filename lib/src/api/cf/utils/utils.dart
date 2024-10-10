import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/types/types.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class CfApiUtils {
  /// decode chain address to bytes
  static List<int> decodeAddress<NETWORKADDRESS>({
    required CfChain chain,
    required NETWORKADDRESS address,
    required CfNetwork network,
  }) {
    switch (chain) {
      case CfChain.arbitrum:
      case CfChain.ethereum:
        return decodeEthereumAddress(address);
      case CfChain.bitcoin:
        return decodeBitcoinAddress(
            address: address, network: network.bitcoinNetwork);
      case CfChain.solana:
        return decodeSolanaAddress(address);
      case CfChain.polkadot:
        return decodeSubstrateAddress(address);
      default:
        throw DartCfPluginException("Chain address does not supported");
    }
  }

  /// get chain from subsrate variant key
  static CfChain getChainFromVariant<NETWORKADDRESS>(
      Map<String, dynamic> result) {
    String? variant;
    if (result.isNotEmpty) {
      variant = result.keys.first;
    }
    return CfChain.fromVariant(variant);
  }

  /// encode address to string from substrate metadata result
  static Tuple<String, CfChain> encodeVariantAddress(
      {required Map<String, dynamic> result, required CfNetwork network}) {
    try {
      final chain = getChainFromVariant(result);
      final List<int> bytes = List<int>.from(result[chain.getChainVariant()]);
      String address;
      switch (chain) {
        case CfChain.arbitrum:
        case CfChain.ethereum:
          address = ETHAddress.fromBytes(bytes).address;
          break;
        case CfChain.solana:
          address = SolAddress.uncheckBytes(bytes).address;
          break;
        case CfChain.polkadot:
          address = SubstrateAddress.fromBytes(bytes).address;
          break;
        case CfChain.bitcoin:
          address = BitcoinAddress(StringUtils.decode(bytes),
                  network: network.bitcoinNetwork)
              .address;
          break;
        default:
          throw UnimplementedError();
      }
      return Tuple(address, chain);
    } on DartCfPluginException {
      rethrow;
    } catch (e) {
      throw DartCfPluginException("Encode address failed.",
          details: {"data": result});
    }
  }

  /// decode solana to bytes
  static List<int> decodeSolanaAddress<NETWORKADDRESS>(NETWORKADDRESS address) {
    if (address is! SolAddress) {
      throw DartCfPluginException("Invalid sol address");
    }
    return address.toBytes();
  }

  /// decode ethereum address to bytes
  static List<int> decodeEthereumAddress<NETWORKADDRESS>(
      NETWORKADDRESS address) {
    if (address is! ETHAddress) {
      throw DartCfPluginException("Invalid Ethereum address");
    }
    return address.toBytes();
  }

  /// decode bitcoin address to bytes.
  static List<int> decodeBitcoinAddress<NETWORKADDRESS>(
      {required NETWORKADDRESS address, required BitcoinNetwork network}) {
    if (address is! BitcoinAddress) {
      throw DartCfPluginException("Invalid Bitcoin address");
    }
    return StringUtils.encode(
        BitcoinAddress(address.address, network: network).address);
  }

  /// decode bitcoin program address to bytes
  static List<int> decodeBitcoinProgramAddress<NETWORKADDRESS>(
      NETWORKADDRESS address) {
    if (address is! BitcoinAddress) {
      throw DartCfPluginException("Invalid Bitcoin address");
    }
    return BytesUtils.fromHexString(address.baseAddress.addressProgram);
  }

  /// decode substrate address to bytes
  static List<int> decodeSubstrateAddress<NETWORKADDRESS>(
      NETWORKADDRESS address) {
    if (address is! SubstrateAddress) {
      throw DartCfPluginException("Invalid Solana address");
    }
    return address.toBytes();
  }

  /// get bitcoin address type for substrate refund params
  static String getBitcoinAddressVariant<NETWORKADDRESS>(
      NETWORKADDRESS address) {
    if (address is! BitcoinAddress) {
      throw DartCfPluginException("Invalid Bitcoin address");
    }
    if (address.type.isP2sh) {
      return "P2SH";
    }
    switch (address.type) {
      case SegwitAddresType.p2tr:
        return "Taproot";
      case SegwitAddresType.p2wpkh:
        return "P2WPKH";
      case SegwitAddresType.p2wsh:
        return "P2WSH";
      case P2pkhAddressType.p2pkh:
        return "P2PKH";
      default:
        throw DartCfPluginException("Bitcoin address does not supported.",
            details: {"type": address.type.value});
    }
  }

  /// get asset from substrate result
  static AssetAndChain getVariantAssets(Map<String, dynamic> json) {
    String? name;
    if (json.isNotEmpty) {
      name = json.keys.first;
    }
    switch (name) {
      case AssetsConst.eth:
      case AssetsConst.flip:
      case AssetsConst.usdc:
      case AssetsConst.usdt:
        return AssetAndChain.ethereum(asset: CfAssets.fromVariant(name));
      case AssetsConst.dot:
        return AssetAndChain.polkadot();
      case AssetsConst.btc:
        return AssetAndChain.bitcoin();
      case AssetsConst.sol:
        return AssetAndChain.solana(asset: CfAssets.sol);
      case AssetsConst.solUsdc:
        return AssetAndChain.solana(asset: CfAssets.usdc);
      case AssetsConst.arbEth:
        return AssetAndChain.arbitrum();
      case AssetsConst.arbUsdc:
        return AssetAndChain.arbitrum(asset: CfAssets.usdc);
    }
    throw DartCfPluginException("Asset not found.", details: {"name": name});
  }

  static List<int> asEthereumUnit32(List<int> bytes) {
    if (bytes.length > 32) {
      throw DartCfPluginException("overflow 32 bytes.");
    }
    if (bytes.length == 32) {
      return bytes;
    }
    final bytes32 = List<int>.filled(32, 0);
    bytes32.setAll(32 - bytes.length, bytes);
    return bytes32;
  }
}
