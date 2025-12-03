import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/movie_details_provider.dart';
import '../../widgets/movie_horizontal_list.dart';
import '../../services/watchlist_service.dart';
import '../../models/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    late final String movieId;
    String? heroTag;
    if (args is Map && args['id'] is String) {
      movieId = args['id'] as String;
      heroTag = args['heroTag'] as String?;
    } else if (args is String) {
      movieId = args;
    } else {
      throw ArgumentError('MovieDetailsScreen requires a movie id');
    }

    final provider = Provider.of<MovieDetailsProvider>(context, listen: false);
    return FutureBuilder(
      future: provider.loadMovie(movieId),
      builder: (_, snapshot) {
        final detailsState = Provider.of<MovieDetailsProvider>(context);
        final movie = detailsState.movie;
        if (movie == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final genres = movie.genres ?? [];
        final similar = detailsState.similar;
        final cast = detailsState.cast;
        final effectiveHeroTag = heroTag ?? 'hero_${movie.id}';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: effectiveHeroTag,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(movie.posterUrl, fit: BoxFit.cover),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text('${movie.vote ?? 0}'),
                        const SizedBox(width: 12),
                        if (movie.releaseDate != null)
                          Text(movie.releaseDate!.split('-').first),
                      ]),
                      const SizedBox(height: 16),
                      _FavoriteButton(movie: movie),
                      const SizedBox(height: 16),
                      if (genres.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: genres
                              .map((g) => Chip(label: Text(g)))
                              .toList(),
                        ),
                      const SizedBox(height: 24),
                      const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(movie.overview ?? ''),
                      const SizedBox(height: 24),
                      if (cast.isNotEmpty) ...[
                        const Text('Casting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cast.length,
                            itemBuilder: (_, index) {
                              final member = cast[index];
                              final profile = member['profile_path'];
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 38,
                                      backgroundImage: profile != null
                                          ? NetworkImage('https://image.tmdb.org/t/p/w185$profile')
                                          : null,
                                      backgroundColor: Colors.grey.shade800,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member['name'] ?? '',
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      member['character'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (similar.isNotEmpty) ...[
                        const Text('Films similaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        MovieHorizontalList(
                          similar,
                          heroTagBuilder: (m, index) => 'hero_similar_${movie.id}_${m.id}_$index',
                          onMovieTap: (m, tag) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/details',
                              arguments: {'id': m.id, 'heroTag': tag},
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final Movie movie;
  const _FavoriteButton({required this.movie});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<List<String>>(
      stream: WatchlistService.watchlistStream(user.uid),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? const <String>[];
        final isFavorite = favorites.contains(movie.id);
        return FilledButton.icon(
          icon: Icon(isFavorite ? Icons.check : Icons.favorite_border),
          label: Text(isFavorite ? 'Dans vos favoris' : 'Ajouter aux favoris'),
          onPressed: () async {
            if (isFavorite) {
              await WatchlistService.removeFromWatchlist(movie.id);
            } else {
              await WatchlistService.addToWatchlist(movie.id);
            }
          },
        );
      },
    );
  }
}