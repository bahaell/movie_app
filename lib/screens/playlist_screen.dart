import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<AppUser?>(
        future: _firestoreService.getUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.favorites.isEmpty) {
            return const Center(
              child: Text('You haven\'t added any movies yet'),
            );
          }

          final user = snapshot.data!;
          return ListView.builder(
            itemCount: user.favorites.length,
            itemBuilder: (context, index) {
              final movieId = user.favorites[index];
              return ListTile(
                leading: const Icon(Icons.movie),
                title: Text('Movie ID: $movieId'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final updatedFavorites = [...user.favorites]..removeAt(index);
                    _firestoreService.updateFavorites(userId, updatedFavorites);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
