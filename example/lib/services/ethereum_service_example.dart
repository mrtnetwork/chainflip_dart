import 'dart:convert';
import 'package:chainflip_dart/chainflip_dart.dart';
import 'package:http/http.dart';

class EthereumHttpService with JSONRPCService {
  EthereumHttpService(this.url,
      {Client? client, this.defaultTimeOut = const Duration(seconds: 30)})
      : client = client ?? Client();

  @override
  final String url;
  final Client client;
  final Duration defaultTimeOut;
  @override
  Future<Map<String, dynamic>> call(ETHRequestDetails params,
      [Duration? timeout]) async {
    final response = await client
        .post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: params.toRequestBody())
        .timeout(timeout ?? defaultTimeOut);
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data;
  }
}
