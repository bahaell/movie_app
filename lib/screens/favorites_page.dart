import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<int, dynamic> _movieCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preloadMovieData();
  }

  Future<void> _preloadMovieData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final favorites = userDoc.data()?["favorites"] as List<dynamic>? ?? [];

      // Récupère les informations TMDB pour les favoris
      // (note: Dans une vraie app, on utiliserait une API endpoint spécifique)
      // Pour l'instant, on affiche juste les IDs
      setState(() => _isLoading = false);
    } catch (e) {
      print("Error preloading movies: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(int movieId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({
        "favorites": FieldValue.arrayRemove([movieId])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                // defensively handle no data / no document / offline scenarios
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
                    ),
                  );
                }

                final doc = snapshot.data;
                final docData = doc == null ? null : doc.data();

                if (docData == null || docData is! Map<String, dynamic>) {
                  // no user document or empty data -> show empty state
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFF53fc18).withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No favorites yet",
                          style: TextStyle(
                            color: Color(0xFF53fc18),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Your profile doesn't have a favorites list yet.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final favorites = docData as Map<String, dynamic>;
                final favoriteList = (favorites["favorites"] as List<dynamic>?) ?? [];

                if (favoriteList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFF53fc18).withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No favorites yet",
                          style: TextStyle(
                            color: Color(0xFF53fc18),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Add movies from the catalog",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final movieId = favoriteList[index] as int;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF53fc18),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Movie #$movieId",
                                  style: const TextStyle(
                                    color: Color(0xFF53fc18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Favorite",
                                    style: TextStyle(
                                      color: Color(0xFF53fc18),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeFromFavorites(movieId),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFF53fc18),
                                    size: 20,
                                  ),
                                  constraints:
                                      const BoxConstraints(maxWidth: 35),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
