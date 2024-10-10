import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:chainflip_dart/src/exception/exception.dart';

enum VaultContractChain { eth, arbitrum }

class CfNetwork {
  final String name;
  final String backendUrl;
  final String rpcUrl;
  final bool isMainnet;
  BitcoinNetwork get bitcoinNetwork {
    if (isMainnet) return BitcoinNetwork.mainnet;
    return BitcoinNetwork.testnet;
  }

  BigInt get stateChainId {
    switch (this) {
      case CfNetwork.mainnet:
        return BigInt.one;
      case CfNetwork.backspin:
        return BigInt.from(10997);
      case CfNetwork.sisyphos:
      case CfNetwork.perseverance:
        return BigInt.from(11155111);
      default:
        throw DartCfPluginException("Invalid chain flip network.");
    }
  }

  BigInt vaultChainId(VaultContractChain chain) {
    if (chain == VaultContractChain.eth) return stateChainId;
    switch (this) {
      case CfNetwork.mainnet:
        return BigInt.from(42161);
      case CfNetwork.backspin:
        return BigInt.from(412346);
      case CfNetwork.sisyphos:
      case CfNetwork.perseverance:
        return BigInt.from(421614);
      default:
        throw DartCfPluginException("Invalid chain flip network.");
    }
  }

  String getValueContractAddress(VaultContractChain chain) {
    switch (chain) {
      case VaultContractChain.eth:
        return vaultContractAddress;
      case VaultContractChain.arbitrum:
        return arbVaultContractAddress;
      default:
        throw DartCfPluginException("Invalid Vault chain.");
    }
  }

  final String flipContractAddress;
  final String usdcContractAddress;
  final String usdtContractAddress;
  final String arbUsdcContractAddress;
  final String vaultContractAddress;
  final String stateChainGatewayAddress;
  final String arbVaultContractAddress;
  final String solUsdcContractAddress;

  const CfNetwork._(
      {required this.name,
      required this.backendUrl,
      required this.rpcUrl,
      required this.flipContractAddress,
      required this.usdcContractAddress,
      required this.usdtContractAddress,
      required this.arbUsdcContractAddress,
      required this.vaultContractAddress,
      required this.stateChainGatewayAddress,
      required this.arbVaultContractAddress,
      required this.solUsdcContractAddress,
      this.isMainnet = false});

  static const CfNetwork backspin = CfNetwork._(
    name: 'backspin',
    backendUrl: 'https://chainflip-swap-backspin.staging/',
    rpcUrl: 'https://backspin-rpc.staging',
    flipContractAddress: '0x10C6E9530F1C1AF873a391030a1D9E8ed0630D26',
    usdcContractAddress: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    usdtContractAddress: '0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82',
    arbUsdcContractAddress: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
    vaultContractAddress: '0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968',
    stateChainGatewayAddress: '0xeEBe00Ac0756308ac4AaBfD76c05c4F3088B8883',
    arbVaultContractAddress: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    solUsdcContractAddress: '',
  );

  static const CfNetwork sisyphos = CfNetwork._(
    name: 'sisyphos',
    backendUrl: 'https://chainflip-swap.staging/',
    rpcUrl: 'https://archive.sisyphos.chainflip.io',
    flipContractAddress: '0xcD079EAB6B5443b545788Fd210C8800FEADd87fa',
    usdcContractAddress: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
    usdtContractAddress: '0x27CEA6Eb8a21Aae05Eb29C91c5CA10592892F584',
    arbUsdcContractAddress: '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d',
    vaultContractAddress: '0xa94d6b1853F3cb611Ed3cCb701b4fdA5a9DACe85',
    stateChainGatewayAddress: '0x1F7fE41C798cc7b1D34BdC8de2dDDA4a4bE744D9',
    arbVaultContractAddress: '0x8155BdD48CD011e1118b51A1C82be020A3E5c2f2',
    solUsdcContractAddress: '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU',
  );

  static const CfNetwork perseverance = CfNetwork._(
    name: 'perseverance',
    backendUrl: 'https://chainflip-swap-perseverance.chainflip.io/',
    rpcUrl: 'https://archive.perseverance.chainflip.io',
    flipContractAddress: '0xdC27c60956cB065D19F08bb69a707E37b36d8086',
    usdcContractAddress: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
    usdtContractAddress: '0x27CEA6Eb8a21Aae05Eb29C91c5CA10592892F584',
    arbUsdcContractAddress: '0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d',
    vaultContractAddress: '0x36eaD71325604DC15d35FAE584D7b50646D81753',
    stateChainGatewayAddress: '0xA34a967197Ee90BB7fb28e928388a573c5CFd099',
    arbVaultContractAddress: '0x2bb150e6d4366A1BDBC4275D1F35892CD63F27e3',
    solUsdcContractAddress: '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU',
  );

  static const CfNetwork mainnet = CfNetwork._(
      name: 'mainnet',
      backendUrl: 'https://chainflip-swap.chainflip.io/',
      rpcUrl: 'https://rpc.mainnet.chainflip.io',
      flipContractAddress: '0x826180541412D574cf1336d22c0C0a287822678A',
      usdcContractAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      usdtContractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      arbUsdcContractAddress: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
      vaultContractAddress: '0xF5e10380213880111522dd0efD3dbb45b9f62Bcc',
      stateChainGatewayAddress: '0x6995Ab7c4D7F4B03f467Cf4c8E920427d9621DBd',
      arbVaultContractAddress: '0x79001a5e762f3bEFC8e5871b42F6734e00498920',
      solUsdcContractAddress: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      isMainnet: true);
}
