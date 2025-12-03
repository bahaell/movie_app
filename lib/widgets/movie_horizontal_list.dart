import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie movie, String heroTag)? onMovieTap;
  final String Function(Movie movie, int index)? heroTagBuilder;
  const MovieHorizontalList(
    this.movies, {
    super.key,
    this.onMovieTap,
    this.heroTagBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (_, i) {
          final m = movies[i];
          final heroTag = heroTagBuilder?.call(m, i) ?? 'hero_${m.id}_$i';
          return GestureDetector(
            onTap: () => onMovieTap?.call(m, heroTag),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        m.posterUrl,
                        height: 220,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}