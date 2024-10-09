import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'servers/model.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  Server? _server;
  final List<String> _stream = [];

  @override
  Widget build(BuildContext context) {
    var connected = (_server != null && _server!.connected);
    log('connected = $connected');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true),
      title: "Nautilus",
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Nautilus'),
        ),
        body: !connected
            ? ConnectServer(
                onConnect: (server) {
                  setState(() {
                    _server = server;
                  });
                },
              )
            : Console(
                server: _server!,
                onDisconnect: () {
                  if (_server == null) {
                    return;
                  }
                  _server!.disconnect();
                  setState(() {
                    _server = null;
                  });
                },
              ),
      ),
    );
  }
}

class ConnectServer extends StatefulWidget {
  const ConnectServer({Function(Server)? onConnect, super.key})
      : _onConnect = onConnect;

  final Function(Server)? _onConnect;

  @override
  State<StatefulWidget> createState() => _ConnectServerState();
}

class _ConnectServerState extends State<ConnectServer> {
  String _host = 'localhost';
  int _port = 3030;

  connect() async {
    var server = Server(host: _host, port: _port);
    await server.connect();
    if (widget._onConnect != null) {
      widget._onConnect!(server);
    }
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

class Console extends StatefulWidget {
  const Console({required Server server, Function()? onDisconnect, super.key})
      : _server = server,
        _onDisconnect = onDisconnect;

  final Server _server;
  final Function()? _onDisconnect;

  @override
  State<StatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  final List<Widget> _messages = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._server.stream(),
      builder: (context, snapshot) {
        var messages = [..._messages];
        if (snapshot.hasData) {
          var message = String.fromCharCodes(snapshot.data! as Uint8List);
          messages.add(Text(message));
          log('incoming stream data: $message');
        }
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: ListView(
                children: messages,
              ),
            ),
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    if (widget._onDisconnect != null) {
                      widget._onDisconnect!();
                    }
                  },
                  child: const Text('Disconnect')),
            )
          ],
        );
      },
    );
  }
}
