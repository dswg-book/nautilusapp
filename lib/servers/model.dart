import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Server {
  Server({required String host, required int port}) : _host = host, _port = port;

  final String _host;
  final int _port;
  Socket? _socket;

  get host => _host;
  get port => _port;
  get connected => _socket != null;

  connect() async {
    _socket = await Socket.connect(_host, _port);
    _socket!.handleError((error) {log('socket error: $error');});
  }

  disconnect() async {
    if (_socket != null) {
      await _socket!.close();
      _socket == null;
    }
  }

  stream() {
    if (_socket == null) {
      return;
    }
    return _socket!.asBroadcastStream();
    // _socket!.asBroadcastStream().listen(
    //   (event) {
    //     var data = String.fromCharCodes(event);
    //     log('incoming event: $data');
    //   },
    // );
  }

  send(String input) {
    if (_socket == null) {
      return;
    }
    _socket!.write(input);
  }
}
