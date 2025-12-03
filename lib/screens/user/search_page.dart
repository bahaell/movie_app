import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/movie.dart';
import '../../services/firebase_movie_service.dart';
import '../../widgets/movie_card.dart';
import 'movie_details_firestore.dart';

class SearchPageUser extends StatefulWidget {
  const SearchPageUser({super.key});

  @override
  State<SearchPageUser> createState() => _SearchPageUserState();
}

class _SearchPageUserState extends State<SearchPageUser> {
  final FirebaseMovieService _movieService = FirebaseMovieService();
  final TextEditingController _controller = TextEditingController();
  List<Movie> results = [];
  bool loading = false;

  Future<void> searchMovies() async {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      setState(() {
        results = [];
      });
      return;
    }

    setState(() => loading = true);
    try {
      final matches = await _movieService.searchMovies(q);
      if (!mounted) return;
      setState(() {
        results = matches;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE_DARK,
      appBar: AppBar(
        backgroundColor: SURFACE_DARK,
        title: const Text('Search', style: TextStyle(color: PRIMARY_GREEN)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => searchMovies(),
              decoration: InputDecoration(
                hintText: 'Search movie...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade800,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: PRIMARY_GREEN),
                  onPressed: searchMovies,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() => results = []);
                }
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: PRIMARY_GREEN),
                  )
                : results.isEmpty && _controller.text.isNotEmpty
                    ? const Center(
                        child: Text(
                          'Aucun film trouvé',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: .65,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final movie = results[i];
                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailsFirestore(movieId: movie.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
