class Server {
  const Server({required String host, required int port}) : _host = host, _port = port;

  final String _host;
  final int _port;

  get host => _host;
  get port => _port;
}
