import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model.g.dart';

@riverpod
class Server extends _$Server {
  Server();
  Server.withOptions({required this.host, required this.port});

  String host = '';
  int port = 0;
  Socket? socket;
  final List<String> messages = [];

  get connected => socket != null;

  @override
  Stream<List<String>> build() async* {
    if (socket != null) {
      final stream = socket!.asBroadcastStream(
        onCancel: (subscription) {
          log('stream cancelled');
          subscription.cancel();
          socket = null;
        },
      );
      await for (var data in stream) {
        messages.add(utf8.decode(data));
        yield messages;
      }
    }
  }

  connect() async {
    socket = await Socket.connect(host, port);
    socket!.handleError((error) {
      log('socket error: $error');
      socket = null;
    });
  }

  disconnect() async {
    if (socket != null) {
      messages.clear();
      await socket!.close();
      socket == null;
    }
  }

  send(String input) {
    if (socket == null) {
      return;
    }
    socket!.write('$input\n');
  }
}

class ServerStream extends ConsumerWidget {
  const ServerStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serverProvider);
    return Scaffold(
        body: state.when(
      data: (data) => ListView(
        children: data.map((e) => Text(e)).toList(),
      ),
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => const CircularProgressIndicator(),
    ));
  }
}
