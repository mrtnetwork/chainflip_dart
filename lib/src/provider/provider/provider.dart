import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:chainflip_dart/src/provider/core/core.dart';
import 'package:chainflip_dart/src/provider/service/service.dart';

class CfProvider {
  final CfServiceProvider rpc;

  CfProvider(this.rpc);

  int _id = 0;

  static Object? _findError(
      {required ChainFlipRequestResponse response,
      required CfRequestDetails request}) {
    final data = StringUtils.tryToJson(response.response);
    if (!response.isSuccess) {
      throw RPCError(
          message: (response.response?.isEmpty ?? true)
              ? "Requst failed with status code: ${response.statusCode}"
              : response.response!,
          errorCode: null,
          details: data);
    }
    if (request.requestType == HTTPRequestType.post) {
      if (data == null) {
        throw RPCError(
            message: (response.response?.isEmpty ?? true)
                ? "Invalid RPC response."
                : response.response!,
            errorCode: null,
            details: {
              "response": response.response,
              "statusCode": response.statusCode
            });
      }
      final Map<String, dynamic>? error = data["error"];
      if (error != null) {
        throw RPCError(
            message: error["message"] ?? response.response,
            errorCode: error["code"],
            details: data);
      }
      return data["result"];
    }
    return data;
  }

  Future<dynamic> requestDynamic(CfRequestParam request,
      [Duration? timeout]) async {
    final id = ++_id;
    final params = request.toRequest(id);
    final data = params.requestType == HTTPRequestType.post
        ? await rpc.post(params, timeout)
        : await rpc.get(params, timeout);
    return _findError(request: params, response: data);
  }

  Future<T> request<T, E>(CfRequestParam<T, E> request,
      [Duration? timeout]) async {
    final data = await requestDynamic(request, timeout);
    final Object result;
    if (E == List<Map<String, dynamic>>) {
      result = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      result = data;
    }
    return request.onResonse(result as E);
  }
}
