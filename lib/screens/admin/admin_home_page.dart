import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movies/movie_management_page.dart';
import 'users/user_management_page.dart';
import 'profile/admin_profile_page.dart';

// Admin Home with Bottom Navigation
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _index = 0;
  final pages = [const AdminMoviesPage(), const AdminUsersPage(), const AdminProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Admin Panel', style: TextStyle(color: Color(0xFF53FC18))),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF53FC18)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF53FC18),
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Utilisateurs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
