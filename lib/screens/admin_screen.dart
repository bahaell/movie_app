import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Users Management'),
            leading: const Icon(Icons.people),
            onTap: () {
              // TODO: Implement users management
            },
          ),
          ListTile(
            title: const Text('Movies Management'),
            leading: const Icon(Icons.movie),
            onTap: () {
              // TODO: Implement movies management
            },
          ),
          ListTile(
            title: const Text('Reports'),
            leading: const Icon(Icons.assessment),
            onTap: () {
              // TODO: Implement reports
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
    );
  }
}
