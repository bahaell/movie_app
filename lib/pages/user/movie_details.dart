import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';
import '../../models/cast.dart';
import '../../models/review.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    details = await MovieService.details(widget.movieId);
    cast = await MovieService.cast(widget.movieId);
    reviews = await MovieService.reviews(widget.movieId);
    similar = await MovieService.similar(widget.movieId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(details['title'] ?? 'Détails', style: const TextStyle(color: Color(0xFF53fc18))),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (details['poster_path'] != null)
                        Image.network(MovieService.getImageUrl(details['poster_path']), width: 120),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(details['title'] ?? '', style: const TextStyle(color: Color(0xFF53fc18), fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Rating: ${details['vote_average'] ?? '-'}', style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('Runtime: ${details['runtime'] ?? '-'} min', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Overview', style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(details['overview'] ?? '', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text('Cast', style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
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
                        final img = profile != null ? MovieService.getImageUrl(profile) : '';
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: img.isNotEmpty
                                    ? Image.network(img, height: 70, width: 70, fit: BoxFit.cover)
                                    : Container(height: 70, width: 70, color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 6),
                              Text(name, style: const TextStyle(color: Color(0xFF53fc18)), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Reviews', style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...reviews.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['author'] ?? 'Anonymous', style: const TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(r['content'] ?? '', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text('Similar Movies', style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: similar.length,
                      itemBuilder: (context, index) {
                        final s = similar[index];
                        final title = s['title'] ?? '';
                        final poster = s['poster_path'];
                        final img = poster != null ? MovieService.getImageUrl(poster) : '';
                        return Column(
                          children: [
                            Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: img.isNotEmpty
                                        ? Image.network(img, height: 200, width: 140, fit: BoxFit.cover)
                                        : Container(height: 200, width: 140, color: Colors.grey[800]),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(title, style: const TextStyle(color: Color(0xFF53fc18)), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
