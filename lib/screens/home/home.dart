import 'package:flutter/material.dart';
import 'package:gospl/services/auth.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text('Scriptures!'),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: const Icon(Icons.person),
            label: const Text('logout'),
          )
        ],
      ),
    );
  }
}
