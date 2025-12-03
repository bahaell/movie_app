import 'package:flutter/material.dart';
import '../../services/tmdb_service.dart';
import '../../services/firebase_movie_service.dart';
import '../../core/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/movie.dart';

class AdminMovieDetailsPage extends StatefulWidget {
  final String movieId; // tmdb id or firestore doc id (same if imported)
  const AdminMovieDetailsPage({super.key, required this.movieId});

  @override State<AdminMovieDetailsPage> createState() => _AdminMovieDetailsPageState();
}

class _AdminMovieDetailsPageState extends State<AdminMovieDetailsPage> {
  Map<String,dynamic>? tmdb;
  Movie? dbMovie;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(()=> loading = true);
  tmdb = await TmdbService.fetchMovieById(widget.movieId);
  dbMovie = await FirebaseMovieService().getMovie(widget.movieId);
    setState(()=> loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black), body: const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN)));
  final title = tmdb?['title'] ?? dbMovie?.title ?? 'No title';
  final poster = tmdb?['poster_path'] != null
    ? '$TMDB_BASE_IMG${tmdb!['poster_path']}'
    : (dbMovie != null && dbMovie!.posterUrl.isNotEmpty ? dbMovie!.posterUrl : null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title, style: const TextStyle(color: PRIMARY_GREEN)), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (poster != null) CachedNetworkImage(imageUrl: poster),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: PRIMARY_GREEN, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(tmdb?['overview'] ?? dbMovie?.overview ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          if (tmdb?['genres'] != null)
            Wrap(spacing: 8, children: (tmdb!['genres'] as List).map((g)=> Chip(label: Text(g['name']))).toList())
          else if ((dbMovie?.genres ?? []).isNotEmpty)
            Wrap(spacing: 8, children: dbMovie!.genres!.map((g) => Chip(label: Text(g))).toList()),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_GREEN),
            onPressed: () {
              // Potential: launch URL to TMDB
            },
            icon: const Icon(Icons.open_in_new, color: Colors.black),
            label: const Text('Open TMDB', style: TextStyle(color: Colors.black)),
          ),
        ]),
      ),
    );
  }
}