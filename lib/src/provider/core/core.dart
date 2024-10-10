import 'package:blockchain_utils/utils/string/string.dart';
import 'package:chainflip_dart/src/exception/exception.dart';
import 'package:chainflip_dart/src/provider/utils/utils.dart';

enum HTTPRequestType { post, get }

abstract class CfRequestParams {
  abstract final String method;
}

abstract class CfRequestParam<RESULT, RESPONSE> implements CfRequestParams {
  const CfRequestParam();
  List<String> get pathParameters => [];
  Map<String, dynamic>? get queryParameters => null;

  RESULT onResonse(RESPONSE result) {
    return result as RESULT;
  }

  CfRequestDetails toRequest(int v) {
    final pathParams = ChainFlipProviderUtils.extractParams(method);
    if (pathParams.length != pathParameters.length) {
      throw DartCfPluginException("Invalid Path Parameters.", details: {
        "pathParams": pathParameters,
        "ExceptedPathParametersLength": pathParams.length
      });
    }
    String params = method;
    for (int i = 0; i < pathParams.length; i++) {
      params = params.replaceFirst(pathParams[i], pathParameters[i]);
    }
    final queryParams = Map<String, dynamic>.from(this.queryParameters ?? {});
    print(queryParams);
    if (queryParams.isNotEmpty) {
      params = Uri(path: params, queryParameters: queryParams)
          // .normalizePath()
          .toString();
    }
    return CfRequestDetails(id: v, pathParams: params);
  }
}

abstract class CfRPCRequestParam<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfRPCRequestParam();
  List<dynamic> get params => [];
  final Map<String, String>? header = null;

  @override
  CfRequestDetails toRequest(int v) {
    return CfRequestDetails(
        id: v,
        requestType: HTTPRequestType.post,
        pathParams: method,
        body: StringUtils.fromJson({
          "jsonrpc": '2.0',
          "id": v.toString(),
          "method": method,
          "params": params
        }));
  }
}

class CfRequestDetails {
  const CfRequestDetails(
      {required this.id,
      this.pathParams,
      this.header = const {},
      this.requestType = HTTPRequestType.get,
      this.body});

  CfRequestDetails copyWith({
    int? id,
    String? pathParams,
    HTTPRequestType? requestType,
    Map<String, String>? header,
    String? body,
  }) {
    return CfRequestDetails(
      id: id ?? this.id,
      pathParams: pathParams ?? this.pathParams,
      requestType: requestType ?? this.requestType,
      header: header ?? this.header,
      body: body ?? this.body,
    );
  }

  /// Unique identifier for the request.
  final int id;

  /// URL path parameters
  final String? pathParams;

  final HTTPRequestType requestType;

  final Map<String, String> header;

  final String? body;

  /// Generates the complete request URL by combining the base URI and method-specific URI.
  String url(String uri, {String? brokerUrl}) {
    if (pathParams == "broker_requestSwapDepositAddress") {
      if (brokerUrl == null) {
        throw UnimplementedError(
            "brokerUrl must be set for broker request. `broker_requestSwapDepositAddress`");
      }
      uri = brokerUrl;
    }
    if (requestType == HTTPRequestType.post) {
      return "$uri/";
    }
    String url = uri;
    // if (!url.contains(version)) {
    //   if (url.endsWith("/")) {
    //     url = url + version;
    //   } else {
    //     url = "$url/$version";
    //   }
    // }
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }
    print("$url$pathParams");
    return "$url$pathParams";
  }
}
