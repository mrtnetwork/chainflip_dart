import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chainflip_dart/chainflip_dart.dart';
import 'request_completer.dart';

class ElectrumTCPService with BitcoinBaseElectrumRPCService {
  ElectrumTCPService._(
    this.url,
    Socket channel, {
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  }) : _socket = channel {
    _subscription =
        _socket!.listen(_onMessge, onError: _onClose, onDone: _onDone);
  }
  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  final Duration defaultRequestTimeOut;

  Map<int, AsyncRequestCompleter> requests = {};
  bool _isDiscounnect = false;

  bool get isConnected => _isDiscounnect;

  @override
  final String url;

  void add(List<int> params) {
    if (_isDiscounnect) {
      throw StateError("socket has been discounected");
    }
    _socket?.add(params);
  }

  void _onClose(Object? error) {
    _isDiscounnect = true;

    _socket = null;
    _subscription?.cancel().catchError((e) {});
    _subscription = null;
  }

  void _onDone() {
    _onClose(null);
  }

  void discounnect() {
    _onClose(null);
  }

  static Future<ElectrumTCPService> connect(
    String url, {
    Iterable<String>? protocols,
    Duration defaultRequestTimeOut = const Duration(seconds: 30),
    final Duration connectionTimeOut = const Duration(seconds: 30),
  }) async {
    final parts = url.split(":");
    final channel = await Socket.connect(parts[0], int.parse(parts[1]))
        .timeout(connectionTimeOut);

    return ElectrumTCPService._(url, channel,
        defaultRequestTimeOut: defaultRequestTimeOut);
  }

  void _onMessge(List<int> event) {
    final Map<String, dynamic> decode = json.decode(utf8.decode(event));
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = requests.remove(id);
      request?.completer.complete(decode);
    }
  }

  @override
  Future<Map<String, dynamic>> call(ElectrumRequestDetails params,
      [Duration? timeout]) async {
    final AsyncRequestCompleter compeleter =
        AsyncRequestCompleter(params.params);

    try {
      requests[params.id] = compeleter;
      add(params.toWebSocketParams());
      final result = await compeleter.completer.future
          .timeout(timeout ?? defaultRequestTimeOut);
      return result;
    } finally {
      requests.remove(params.id);
    }
  }
}
