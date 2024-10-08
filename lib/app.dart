import 'package:flutter/material.dart';
import 'package:nautilusapp/servers/drawer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true
      ),
      title: "Nautilus",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Nautilus'),
        ),
        drawer: Drawer(
          child: ServersDrawer(),
        ),
        body: const Center(
          child: Text('Home'),
          ),
        ),
      );
  }
  
}
