import 'package:flutter/material.dart';
import '../../services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_movie_service.dart';
import '../../core/constants.dart';
import '../../models/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final moviesSvc = FirebaseMovieService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Mes Favoris', style: TextStyle(color: PRIMARY_GREEN))),
      body: StreamBuilder<List<String>>(
        stream: WatchlistService.watchlistStream(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN));
          final favs = snap.data!;
          if (favs.isEmpty) return const Center(child: Text('Aucun favori', style: TextStyle(color: PRIMARY_GREEN)));
          return FutureBuilder(
            future: Future.wait(favs.map((id) => moviesSvc.getMovie(id)).toList()),
            builder: (context, AsyncSnapshot<List<Movie?>> s2) {
              if (!s2.hasData) return const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN));
              final movies = s2.data!.whereType<Movie>().toList();
              return ListView.builder(
                itemCount: movies.length,
                itemBuilder: (_, i) {
                  final movie = movies[i];
                  final poster = movie.posterUrl.isNotEmpty ? movie.posterUrl : null;
                  return Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: poster != null
                          ? CachedNetworkImage(imageUrl: poster, width: 60, fit: BoxFit.cover)
                          : null,
                      title: Text(movie.title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        (movie.overview ?? '').length > 80
                            ? '${movie.overview!.substring(0, 80)}...'
                            : (movie.overview ?? ''),
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/details', arguments: movie.id),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: PRIMARY_GREEN),
                        onPressed: () async {
                          await WatchlistService.removeFromWatchlist(movie.id);
                        },
                      ),
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
