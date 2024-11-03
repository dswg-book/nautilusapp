import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'servers/model.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.watch(serverProvider);
    final server = ref.watch(serverProvider.notifier);
    log('connected: ${server.connected}, host: ${server.host}, port: ${server.port}');

    final sendController = TextEditingController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      title: "Nautilus",
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Nautilus'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: !server.connected
                  ? Container()
                  : ElevatedButton.icon(
                      onPressed: () async =>
                          await ref.watch(serverProvider.notifier).disconnect(),
                      icon: const Icon(Icons.offline_bolt_rounded),
                      label: const Text('Disconnect'),
                    ),
            )
          ],
        ),
        body: !server.connected
            ? ConnectServer(ref)
            : Column(
                children: [
                  const Expanded(
                    flex: 3,
                    child: ServerStream(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: sendController,
                        autofocus: true,
                        onSubmitted: (value) {
                          sendController.clear();
                          ref.watch(serverProvider.notifier).send(value);
                        },
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class ConnectServer extends StatefulWidget {
  const ConnectServer(this.ref, {super.key});

  final WidgetRef ref;

  @override
  State<StatefulWidget> createState() => _ConnectServerState();
}

class _ConnectServerState extends State<ConnectServer> {
  String _host = 'localhost';
  int _port = 3030;

  connect() async {
    widget.ref.watch(serverProvider.notifier)
      ..host = _host
      ..port = _port;
    await widget.ref.watch(serverProvider.notifier).connect();
    widget.ref.invalidate(serverProvider);
  }

  @override
  Widget build(BuildContext context) {
    var hostController =
        TextEditingController.fromValue(TextEditingValue(text: _host));
    var portController = TextEditingController.fromValue(
        TextEditingValue(text: _port.toString()));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Connect to Server'),
            Row(
              children: [
                const Text(
                  'Host',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      controller: hostController,
                      onChanged: (value) {
                        setState(() {
                          _host = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Port',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: portController,
                      onChanged: (value) {
                        setState(() {
                          _port = int.parse(value);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(onPressed: connect, child: const Text('Connect'))
          ],
        ),
      ),
    );
  }
}
