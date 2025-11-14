import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      favorites = data['favorites'] ?? [];
    }
    setState(() => loading = false);
  }

  Future<void> _remove(int id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'favorites': FieldValue.arrayRemove([id])
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Favorites', style: TextStyle(color: Color(0xFF53fc18)))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? Center(child: Text('No favorites yet', style: TextStyle(color: Color(0xFF53fc18))))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final id = favorites[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF53fc18), width: 2),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: Center(child: Text('Movie #$id', style: const TextStyle(color: Color(0xFF53fc18))))),
                          Row(
                            children: [
                              Expanded(child: Text(''),),
                              IconButton(onPressed: () => _remove(id), icon: const Icon(Icons.delete, color: Color(0xFF53fc18)))
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
