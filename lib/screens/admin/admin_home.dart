import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import 'admin_movies_page.dart';
import 'admin_users_page.dart';
import 'admin_library_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _idx = 0;

  final _pages = [
    const AdminMoviesPage(), // TMDB import
    const AdminLibraryPage(), // Firebase library & filters
    const AdminUsersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: PRIMARY_GREEN)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          )
        ],
      ),
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _idx,
        selectedItemColor: PRIMARY_GREEN,
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(()=> _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud_download), label: 'Import'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
      // removed admin-wide search floating button per UX request
      floatingActionButton: null,
    );
  }
}
