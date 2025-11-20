import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../services/tv_service.dart';
import '../../services/watchlist_service.dart';
import '../../widgets/section_title.dart';
import 'movie_details.dart';
import 'tv_details.dart';
import 'search_page.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  List<dynamic> popularMovies = [];
  List<dynamic> nowPlaying = [];
  List<dynamic> topRatedMovies = [];
  List<dynamic> onAirTv = [];
  List<dynamic> popularTv = [];
  List<dynamic> topRatedTv = [];
  Set<String> favorites = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      await Future.wait([
        _fetchPopularMovies(),
        _fetchNowPlaying(),
        _fetchTopRatedMovies(),
        _fetchOnAirTv(),
        _fetchPopularTv(),
        _fetchTopRatedTv(),
        _loadFavorites(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _fetchPopularMovies() async {
    try {
      final data = await MovieService.getPopularMovies();
      if (mounted) setState(() => popularMovies = data);
    } catch (e) {
      print('Error fetching popular movies: $e');
    }
  }

  Future<void> _fetchNowPlaying() async {
    try {
      final data = await MovieService.nowPlaying();
      if (mounted) setState(() => nowPlaying = data);
    } catch (e) {
      print('Error fetching now playing: $e');
    }
  }

  Future<void> _fetchTopRatedMovies() async {
    try {
      final data = await MovieService.topRated();
      if (mounted) setState(() => topRatedMovies = data);
    } catch (e) {
      print('Error fetching top rated movies: $e');
    }
  }

  Future<void> _fetchOnAirTv() async {
    try {
      final data = await TvService.onAir();
      if (mounted) setState(() => onAirTv = data);
    } catch (e) {
      print('Error fetching on air TV: $e');
    }
  }

  Future<void> _fetchPopularTv() async {
    try {
      final data = await TvService.popular();
      if (mounted) setState(() => popularTv = data);
    } catch (e) {
      print('Error fetching popular TV: $e');
    }
  }

  Future<void> _fetchTopRatedTv() async {
    try {
      final data = await TvService.topRated();
      if (mounted) setState(() => topRatedTv = data);
    } catch (e) {
      print('Error fetching top rated TV: $e');
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in')),
          );
        }
        return;
      }

      if (favorites.contains(tag)) {
        await WatchlistService.removeFromWatchlist(id, kind);
        if (mounted) setState(() => favorites.remove(tag));
      } else {
        await WatchlistService.addToWatchlist(id, kind);
        if (mounted) setState(() => favorites.add(tag));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildHorizontalList(List<dynamic> items, bool isMovie) {
    if (items.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            isMovie ? 'No movies available' : 'No TV shows available',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index] as Map<String, dynamic>;
          final id = item['id'] as int;
          final title = isMovie
              ? (item['title'] ?? 'Untitled')
              : (item['name'] ?? 'Untitled');
          final poster = item['poster_path'];
          final favTag = '${isMovie ? "movie" : "tv"}_$id';
          final isFav = favorites.contains(favTag);

          return GestureDetector(
            onTap: () {
              if (isMovie) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailsPage(movieId: id),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TvDetailsPage(tvId: id),
                  ),
                );
              }
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
                    onTap: () => _toggleFavorite(id, isMovie ? 'movie' : 'tv'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Home',
          style:
              TextStyle(color: Color(0xFF53FC18), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            icon: const Icon(Icons.search, color: Color(0xFF53FC18)),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/matching'),
            icon: const Icon(Icons.favorite_border, color: Color(0xFF53FC18)),
            tooltip: 'Find Your Match',
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF53FC18)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Now Playing'),
                  _buildHorizontalList(nowPlaying, true),
                  const SectionTitle(title: 'Popular Movies'),
                  _buildHorizontalList(popularMovies, true),
                  const SectionTitle(title: 'Top Rated Movies'),
                  _buildHorizontalList(topRatedMovies, true),
                  const SectionTitle(title: 'On Air TV'),
                  _buildHorizontalList(onAirTv, false),
                  const SectionTitle(title: 'Popular TV'),
                  _buildHorizontalList(popularTv, false),
                  const SectionTitle(title: 'Top Rated TV'),
                  _buildHorizontalList(topRatedTv, false),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
