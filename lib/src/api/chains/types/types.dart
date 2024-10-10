
import 'package:on_chain/solana/src/address/sol_address.dart';

class SolanaTokenPDAInfo {
  final SolAddress address;
  final SolAddress pdaAddress;
  final SolAddress tokenProgramId;
  const SolanaTokenPDAInfo(
      {required this.address,
      required this.pdaAddress,
      required this.tokenProgramId});
}
