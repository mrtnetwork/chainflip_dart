import 'package:blockchain_utils/blockchain_utils.dart';

class DartCfPluginException extends BlockchainUtilsException {
  DartCfPluginException(String message, {Map<String, dynamic>? details})
      : super(message, details: details);
}
