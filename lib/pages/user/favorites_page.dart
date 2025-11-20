import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../services/tv_service.dart';
import '../../services/watchlist_service.dart';
import 'movie_details.dart';
import 'tv_details.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteIds = [];
  Map<String, Map<String, dynamic>> itemCache = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => loading = false);
        return;
      }

      final favList = await WatchlistService.getWatchlistOnce(uid);
      setState(() => favoriteIds = favList.toList());

      // Preload all items
      for (final fav in favoriteIds) {
        await _loadItem(fav);
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }

    setState(() => loading = false);
  }

  Future<void> _loadItem(String favTag) async {
    try {
      // Parse "movie_123" or "tv_456"
      final parts = favTag.split('_');
      if (parts.length != 2) return;

      final kind = parts[0];
      final id = int.tryParse(parts[1]);
      if (id == null) return;

      Map<String, dynamic>? data;
      if (kind == 'movie') {
        data = await MovieService.details(id);
      } else if (kind == 'tv') {
        data = await TvService.details(id);
      }

      if (data != null && data.isNotEmpty) {
        setState(() {
          itemCache[favTag] = data;
        });
      }
    } catch (e) {
      print('Error loading item $favTag: $e');
    }
  }

  Future<void> _removeFavorite(String favTag) async {
    try {
      final parts = favTag.split('_');
      if (parts.length != 2) return;

      final kind = parts[0];
      final id = int.tryParse(parts[1]);
      if (id == null) return;

      await WatchlistService.removeFromWatchlist(id, kind);

      setState(() {
        favoriteIds.remove(favTag);
        itemCache.remove(favTag);
      });
    } catch (e) {
      print('Error removing favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Favorites',
          style:
              TextStyle(color: Color(0xFF53FC18), fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)),
            )
          : favoriteIds.isEmpty
              ? Center(
                  child: Text(
                    'No favorites yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: favoriteIds.length,
                  itemBuilder: (context, index) {
                    final favTag = favoriteIds[index];
                    final item = itemCache[favTag];
                    final title = item == null
                        ? 'Loading...'
                        : (item['title'] ?? item['name'] ?? 'Untitled');
                    final poster = item?['poster_path'];
                    final imageUrl = poster != null ? '$baseImg$poster' : null;
                    final id = int.tryParse(favTag.split('_')[1]) ?? 0;
                    final kind = favTag.split('_')[0];

                    return GestureDetector(
                      onTap: () {
                        if (item != null) {
                          if (kind == 'movie') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsPage(movieId: id),
                              ),
                            );
                          } else if (kind == 'tv') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TvDetailsPage(tvId: id),
                              ),
                            );
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey.shade800,
                            ),
                            child: item == null || imageUrl == null
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFF53FC18),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black87,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeFavorite(favTag),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Color(0xFF53FC18),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
