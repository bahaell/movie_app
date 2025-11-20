import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/movie_service.dart';
import '../services/watchlist_service.dart';
import '../widgets/section_title.dart';
import '../pages/user/movie_details.dart';
import '../pages/user/search_page.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  List<dynamic> nowPlaying = [];
  List<dynamic> popularMovies = [];
  List<dynamic> topRatedMovies = [];
  Set<String> favorites = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _fetchNowPlaying(),
        _fetchPopularMovies(),
        _fetchTopRatedMovies(),
        _loadFavorites(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNowPlaying() async {
    try {
      final data = await MovieService.nowPlaying();
      if (mounted) {
        setState(() => nowPlaying = data);
      }
    } catch (e) {
      print('Error fetching now playing: $e');
    }
  }

  Future<void> _fetchPopularMovies() async {
    try {
      final data = await MovieService.getPopularMovies();
      if (mounted) {
        setState(() => popularMovies = data);
      }
    } catch (e) {
      print('Error fetching popular movies: $e');
    }
  }

  Future<void> _fetchTopRatedMovies() async {
    try {
      final data = await MovieService.topRated();
      if (mounted) {
        setState(() => topRatedMovies = data);
      }
    } catch (e) {
      print('Error fetching top rated movies: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final favList = await WatchlistService.getWatchlistOnce(uid);
      if (mounted) {
        setState(() => favorites = favList.toSet());
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(int id, String kind) async {
    try {
      final tag = '${kind}_$id';
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in')),
        );
        return;
      }

      if (favorites.contains(tag)) {
        await WatchlistService.removeFromWatchlist(id, kind);
        if (mounted) {
          setState(() => favorites.remove(tag));
        }
      } else {
        await WatchlistService.addToWatchlist(id, kind);
        if (mounted) {
          setState(() => favorites.add(tag));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MovieApp',
          style:
              TextStyle(color: Color(0xFF53FC18), fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout, color: Color(0xFF53FC18)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Now Playing'),
                  _movieHorizontalList(nowPlaying, 'movie'),
                  _buildSectionTitle('Popular Movies'),
                  _movieHorizontalList(popularMovies, 'movie'),
                  _buildSectionTitle('Top Rated Movies'),
                  _movieHorizontalList(topRatedMovies, 'movie'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF53FC18),
        foregroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        ),
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF53FC18),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _movieHorizontalList(List<dynamic> data, String kind) {
    if (data.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No $kind available',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index] as Map<String, dynamic>;
          final id = item['id'] as int;
          final title = item['title'] ?? 'No title';
          final poster = item['poster_path'];
          final favTag = '${kind}_$id';
          final isFav = favorites.contains(favTag);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailsPage(movieId: id),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 140,
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Hero(
                        tag: favTag,
                        child: Container(
                          height: 170,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(
                                poster != null
                                    ? '$baseImg$poster'
                                    : 'https://via.placeholder.com/140x170?text=No+Image',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(id, kind),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFF53FC18),
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
