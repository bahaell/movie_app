import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/movie.dart';
import '../../widgets/movie_card.dart';

class CommonMoviesPage extends StatelessWidget {
  final List<Movie> movies;
  const CommonMoviesPage({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE_DARK,
      appBar: AppBar(
        backgroundColor: SURFACE_DARK,
        title: const Text('Films en commun', style: TextStyle(color: PRIMARY_GREEN)),
      ),
      body: movies.isEmpty
          ? const Center(
              child: Text('Aucun film partagé pour le moment', style: TextStyle(color: Colors.white70)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: movies.length,
              itemBuilder: (_, index) {
                final movie = movies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => Navigator.pushNamed(context, '/details', arguments: movie.id),
                );
              },
            ),
    );
  }
}
