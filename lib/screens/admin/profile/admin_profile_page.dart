import 'package:flutter/material.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          SizedBox(height: 12),
          Text('Admin',
              style: TextStyle(color: Color(0xFF53FC18), fontSize: 20)),
          SizedBox(height: 8),
          Text('Gérer le contenu et les utilisateurs',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
