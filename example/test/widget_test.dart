import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:example/metadata/metadata.dart';
import 'package:example/services/cf_service.dart';
import 'package:example/services/substrate_service_example.dart';

void main() async {
  final provider = SubstrateRPC(SubstrateHttpService(CfNetwork.mainnet.rpcUrl));
  final requestMetadata = await SubstrateIntractApi.atRuntimeMetadata(provider);
  print(requestMetadata!.api.networkSS58Prefix());
  print(requestMetadata!.api.networkSS58Prefix());
}
/// 2112