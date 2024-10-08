import 'package:flutter/material.dart';

class ServersDrawer extends StatefulWidget {
  const ServersDrawer({super.key});

  @override
  State<StatefulWidget> createState() => _ServersDrawerState();
  
}

class _ServersDrawerState extends State<ServersDrawer> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ElevatedButton(onPressed: () {}, child: Text('Add Server')),
        ListTile(title: Text('Example Server'))
      ],
    );
  }

}
