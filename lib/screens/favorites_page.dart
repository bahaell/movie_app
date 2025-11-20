import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/movie_service.dart';
import '../../services/tv_service.dart';
import '../../widgets/movie_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Allow cached keys to be either int or String depending on how IDs
  // are stored in Firestore (some users have values like "movie_12345").
  final Map<dynamic, dynamic> _movieCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preloadFavoritesData();
  }

  Future<void> _preloadFavoritesData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final favorites = userDoc.data()?['favorites'] as List<dynamic>? ?? [];
      // Preload TMDB details for each favorite (movie_123, tv_456 or raw integer)
      for (final fav in favorites) {
        if (_movieCache.containsKey(fav)) continue; // already loaded
        _movieCache[fav] = null; // mark as loading
        final parsedId = _extractNumericId(fav);
        if (parsedId != null) {
          Map<String, dynamic> details = {};
            final isTv = _isTvTag(fav);
            try {
              if (isTv) {
                details = await TvService.details(parsedId);
                if (details.isEmpty) details = {'id': parsedId, 'name': 'TV #$parsedId'};
              } else {
                details = await MovieService.details(parsedId);
                if (details.isEmpty) details = {'id': parsedId, 'title': 'Movie #$parsedId'};
              }
            } catch (_) {
              details = {'id': parsedId};
            }
            details['__kind'] = isTv ? 'tv' : 'movie';
            _movieCache[fav] = details;
        } else {
          _movieCache[fav] = {'raw': fav, '__kind': _isTvTag(fav) ? 'tv' : 'movie'};
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print("Error preloading movies: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isTvTag(dynamic raw) => raw is String && raw.startsWith('tv_');
  bool _isMovieTag(dynamic raw) => raw is String && raw.startsWith('movie_');

  int? _extractNumericId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) {
      final match = RegExp(r'(\d+)').firstMatch(raw);
      if (match != null) return int.tryParse(match.group(0)!);
    }
    return null;
  }

  // Accept the raw stored ID (could be int or String) so arrayRemove
  // uses the exact same value stored in Firestore.
  Future<void> _removeFromFavorites(dynamic movieId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({
        "favorites": FieldValue.arrayRemove([movieId])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                // defensively handle no data / no document / offline scenarios
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
                    ),
                  );
                }

                final doc = snapshot.data;
                final docData = doc == null ? null : doc.data();

                if (docData == null || docData is! Map<String, dynamic>) {
                  // no user document or empty data -> show empty state
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFF53fc18).withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No favorites yet",
                          style: TextStyle(
                            color: Color(0xFF53fc18),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Your profile doesn't have a favorites list yet.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final favorites = docData as Map<String, dynamic>;
                final favoriteList = (favorites["favorites"] as List<dynamic>?) ?? [];

                if (favoriteList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: const Color(0xFF53fc18).withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No favorites yet",
                          style: TextStyle(
                            color: Color(0xFF53fc18),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Add movies from the catalog",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final rawFavorite = favoriteList[index];

                    // Normalize/parse the ID for display and (optional)
                    // TMDB lookups. The stored value may be an int or a
                    // String like "movie_123456". We keep the original
                    // value for removal so Firestore matches the stored
                    // element type exactly.
                    int? movieId;
                    String displayLabel;

                    if (rawFavorite is int) {
                      movieId = rawFavorite;
                      displayLabel = "Movie #$movieId";
                    } else if (rawFavorite is String) {
                      // try to extract digits from the string
                      final match = RegExp(r"(\d+)").firstMatch(rawFavorite);
                      movieId = match != null ? int.tryParse(match.group(0)!) : null;
                      displayLabel = rawFavorite;
                    } else {
                      displayLabel = rawFavorite.toString();
                    }

                    // Attempt to get cached TMDB / TV details
                    final data = _movieCache[rawFavorite];
                    final kind = (data is Map<String, dynamic>)
                        ? (data['__kind'] as String? ?? (_isTvTag(rawFavorite) ? 'tv' : 'movie'))
                        : (_isTvTag(rawFavorite) ? 'tv' : 'movie');

                    return GestureDetector(
                      onTap: () {
                        if (movieId != null) {
                          if (kind == 'tv') {
                            Navigator.pushNamed(context, '/tv', arguments: movieId);
                          } else {
                            Navigator.pushNamed(context, '/movie', arguments: movieId);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF53fc18),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: data == null
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
                                        )
                                      : _buildPosterOrLabel(data as Map<String, dynamic>, displayLabel),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Favorite",
                                      style: TextStyle(
                                        color: Color(0xFF53fc18),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    // Pass the raw stored value so Firestore will
                                    // remove the exact element (string or int).
                                    onPressed: () => _removeFromFavorites(rawFavorite),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color(0xFF53fc18),
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(maxWidth: 35),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildPosterOrLabel(Map<String, dynamic> movieData, String fallbackLabel) {
    final posterPath = movieData['poster_path'] as String?;
    final title = movieData['title'] as String? ?? movieData['name'] as String? ?? fallbackLabel;
    if (posterPath != null && posterPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: CachedNetworkImage(
          imageUrl: MovieService.getImageUrl(posterPath),
          fit: BoxFit.cover,
          placeholder: (ctx, _) => const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
          ),
          errorWidget: (ctx, _, __) => Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF53fc18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF53fc18),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
