import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/watchlist_service.dart';
import '../../services/firebase_movie_service.dart';
import '../../models/movie.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final svc = FirebaseMovieService();
    return Scaffold(
      appBar: AppBar(title: const Text('My Watchlist')),
      body: StreamBuilder<List<String>>(
        stream: WatchlistService.watchlistStream(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final ids = snap.data!;
          if (ids.isEmpty) return const Center(child: Text('No favorites yet'));
          return FutureBuilder(
            future: Future.wait(ids.map((id) => svc.getMovie(id))),
            builder: (context, mvSnap) {
              if (!mvSnap.hasData) return const Center(child: CircularProgressIndicator());
              final movies = mvSnap.data!.whereType<Movie>().toList();
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .65,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: movies.length,
                itemBuilder: (_, i) {
                  final movie = movies[i];
                  final poster = movie.posterUrl.isNotEmpty ? movie.posterUrl : null;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        poster != null ? Image.network(poster, fit: BoxFit.cover, width: double.infinity) : Container(color: Colors.grey.shade800),
                        const Positioned(right: 10, top: 10, child: Icon(Icons.favorite, color: Colors.red, size: 28)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}