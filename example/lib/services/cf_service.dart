import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:http/http.dart' as http;

class CfHttpProvider implements CfServiceProvider {
  CfHttpProvider(
      {required this.url,
      required this.backendUrl,
      http.Client? client,
      this.defaultRequestTimeout = const Duration(seconds: 30),
      this.brokerUrl})
      : client = client ?? http.Client();
  @override
  final String url;
  final String backendUrl;
  final String? brokerUrl;

  final http.Client client;
  final Duration defaultRequestTimeout;

  @override
  Future<ChainFlipRequestResponse> get(CfRequestDetails params,
      [Duration? timeout]) async {
    final parseUrl = Uri.parse(params.url(backendUrl));
    final response = await client.get(parseUrl, headers: {
      'Content-Type': 'application/json',
    }).timeout(timeout ?? defaultRequestTimeout);
    return ChainFlipRequestResponse(
        statusCode: response.statusCode, response: response.body);
  }

  @override
  Future<ChainFlipRequestResponse> post(CfRequestDetails params,
      [Duration? timeout]) async {
    final response = await client
        .post(Uri.parse(params.url(backendUrl, brokerUrl: brokerUrl)),
            headers: {'Content-Type': 'application/json', ...params.header},
            body: params.body)
        .timeout(timeout ?? defaultRequestTimeout);
    return ChainFlipRequestResponse(
        statusCode: response.statusCode, response: response.body);
  }
}
