import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/movie_service.dart';
import '../../services/watchlist_service.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;
  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  Map details = {};
  List cast = [];
  List reviews = [];
  List similar = [];
  bool loading = true;
  bool isFav = false;
  String favTag = '';

  @override
  void initState() {
    super.initState();
    favTag = 'movie_${widget.movieId}';
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    details = await MovieService.details(widget.movieId);
    cast = await MovieService.cast(widget.movieId);
    reviews = await MovieService.reviews(widget.movieId);
    similar = await MovieService.similar(widget.movieId);

    // check watchlist
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final wl = await WatchlistService.getWatchlistOnce(uid);
      final fav = wl.contains(favTag);
      setState(() => isFav = fav);
    } catch (e) {
      print('Error loading watchlist: $e');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(details['title'] ?? 'Détails',
            style: const TextStyle(color: Color(0xFF53FC18))),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster with Hero transition
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (details['poster_path'] != null)
                        Hero(
                          tag: favTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                '$baseImg${details['poster_path']}',
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover),
                          ),
                        )
                      else
                        Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(details['title'] ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF53FC18),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('⭐ ${details['vote_average'] ?? '-'}',
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('⏱ ${details['runtime'] ?? '-'} min',
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final uid =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  if (!isFav) {
                                    await WatchlistService.addToWatchlist(
                                        widget.movieId, 'movie');
                                  } else {
                                    await WatchlistService.removeFromWatchlist(
                                        widget.movieId, 'movie');
                                  }
                                  final wl =
                                      await WatchlistService.getWatchlistOnce(
                                          uid);
                                  setState(() => isFav = wl.contains(favTag));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(isFav ? 0xFF53FC18 : 0xFF888888)),
                              child: Text(isFav ? 'Remove' : 'Add to Watchlist',
                                  style: TextStyle(color: Colors.black)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Overview',
                      style: TextStyle(
                          color: Color(0xFF53FC18),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(details['overview'] ?? '',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  if (cast.isNotEmpty) ...[
                    const Text('Cast',
                        style: TextStyle(
                            color: Color(0xFF53FC18),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        itemBuilder: (context, index) {
                          final c = cast[index];
                          final name = c['name'] ?? '';
                          final profile = c['profile_path'];
                          return Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: profile != null
                                      ? Image.network('$baseImg$profile',
                                          height: 80,
                                          width: 90,
                                          fit: BoxFit.cover)
                                      : Container(
                                          height: 80,
                                          width: 90,
                                          color: Colors.grey.shade800),
                                ),
                                const SizedBox(height: 6),
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (reviews.isNotEmpty) ...[
                    const Text('Reviews',
                        style: TextStyle(
                            color: Color(0xFF53FC18),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...reviews.take(3).map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['author'] ?? 'Anonymous',
                                  style: const TextStyle(
                                      color: Color(0xFF53FC18),
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  (r['content'] ?? '').substring(
                                          0,
                                          ((r['content'] ?? '').length > 200
                                              ? 200
                                              : (r['content'] ?? '').length)) +
                                      '...',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (similar.isNotEmpty) ...[
                    const Text('Similar Movies',
                        style: TextStyle(
                            color: Color(0xFF53FC18),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similar.length,
                        itemBuilder: (context, index) {
                          final s = similar[index];
                          final title = s['title'] ?? '';
                          final poster = s['poster_path'];
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        MovieDetailsPage(movieId: s['id']))),
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: poster != null
                                        ? Image.network('$baseImg$poster',
                                            height: 150,
                                            width: 110,
                                            fit: BoxFit.cover)
                                        : Container(
                                            height: 150,
                                            width: 110,
                                            color: Colors.grey.shade800),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(title,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ]
                ],
              ),
            ),
    );
  }
}
