import 'package:flutter/material.dart';
import '../../services/firebase_movie_service.dart';
import '../../services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/movie.dart';

class MovieDetailsFirestore extends StatefulWidget {
  final String movieId;
  const MovieDetailsFirestore({super.key, required this.movieId});

  @override
  State<MovieDetailsFirestore> createState() => _MovieDetailsFirestoreState();
}

class _MovieDetailsFirestoreState extends State<MovieDetailsFirestore> {
  final FirebaseMovieService svc = FirebaseMovieService();
  Movie? movie;
  bool isFav = false;
  List<Movie> similar = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    final m = await svc.getMovie(widget.movieId);
    if (m == null) {
      if (mounted) {
        setState(() {
          movie = null;
          loading = false;
        });
      }
      return;
    }
    movie = m;

    // check fav
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final wl = await WatchlistService.getWatchlistOnce(uid);
    isFav = wl.contains(widget.movieId);

    // get similar: use genres if present, else search by first word
    List<Movie> found = [];
    try {
      final genres = movie!.genres;
      if (genres != null && genres.isNotEmpty) {
        // query Firestore for movies that have at least one common genre
        final qGenre = genres.first.toString();
        final snap = await svc.moviesRef.where('genres', arrayContains: qGenre).limit(10).get();
        found = snap.docs
            .map((d) => Movie.fromMap({...d.data() as Map<String, dynamic>, 'id': d.id}))
            .where((e) => e.id != widget.movieId)
            .toList();
      } else {
        final titleWord = movie!.title.split(' ').first;
    final snap = await svc.moviesRef
      .where('title', isGreaterThanOrEqualTo: titleWord)
      .where('title', isLessThanOrEqualTo: '$titleWord\uf8ff')
      .limit(10)
      .get();
        found = snap.docs
            .map((d) => Movie.fromMap({...d.data() as Map<String, dynamic>, 'id': d.id}))
            .where((e) => e.id != widget.movieId)
            .toList();
      }
    } catch (_) {
      found = [];
    }

    if (mounted) {
      setState(() {
        similar = found;
        loading = false;
      });
    }
  }

  Future<void> _toggleFav() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (isFav) {
      await WatchlistService.removeFromWatchlist(widget.movieId);
    } else {
      await WatchlistService.addToWatchlist(widget.movieId);
    }
    final wl = await WatchlistService.getWatchlistOnce(uid);
    if (mounted) setState(() => isFav = wl.contains(widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            Shimmer.fromColors(baseColor: Colors.grey.shade800, highlightColor: Colors.grey.shade700, child: Container(height: 220, color: Colors.grey.shade800)),
            const SizedBox(height: 12),
            Shimmer.fromColors(baseColor: Colors.grey.shade800, highlightColor: Colors.grey.shade700, child: Container(height: 20, color: Colors.grey.shade800)),
          ]),
        ),
      );
    }

    if (movie == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: const Center(child: Text('Movie not found', style: TextStyle(color: PRIMARY_GREEN))),
      );
    }

    final poster = movie!.posterUrl.isNotEmpty ? movie!.posterUrl : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(movie!.title, style: const TextStyle(color: PRIMARY_GREEN)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {
            // optional share implementation
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Hero(
            tag: 'movie_${movie!.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: poster != null
                  ? CachedNetworkImage(
                      imageUrl: poster,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade800,
                        highlightColor: Colors.grey.shade700,
                        child: Container(height: 220, color: Colors.grey.shade800),
                      ),
                    )
                  : Container(height: 220, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(movie!.title, style: const TextStyle(color: PRIMARY_GREEN, fontSize: 22, fontWeight: FontWeight.bold))),
            ElevatedButton.icon(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.black),
              label: Text(isFav ? 'Retirer' : 'Favoris', style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_GREEN),
              onPressed: _toggleFav,
            ),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            if (movie!.vote != null)
              Chip(backgroundColor: Colors.grey.shade900, label: Text('⭐ ${movie!.vote}', style: const TextStyle(color: PRIMARY_GREEN))),
            if (movie!.releaseDate != null)
              Chip(backgroundColor: Colors.grey.shade900, label: Text(movie!.releaseDate ?? '', style: const TextStyle(color: Colors.white70))),
            ...(movie!.genres ?? [])
                .map((g) => Chip(backgroundColor: Colors.grey.shade900, label: Text(g, style: const TextStyle(color: Colors.white70))))
                .toList(),
          ]),
          const SizedBox(height: 12),
          Text(movie!.overview ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const Text('Similaires', style: TextStyle(color: PRIMARY_GREEN, fontSize: 18)),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
      child: similar.isEmpty
        ? const Center(child: Text('Aucun similaire', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: similar.length,
                    itemBuilder: (context, i) {
                      final it = similar[i];
                      final p = it.posterUrl.isNotEmpty ? it.posterUrl : null;
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsFirestore(movieId: it.id))),
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: p != null ? CachedNetworkImage(imageUrl: p, height: 120, fit: BoxFit.cover) : Container(height: 120, color: Colors.grey.shade800)),
                            const SizedBox(height: 6),
                            Text(it.title, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
