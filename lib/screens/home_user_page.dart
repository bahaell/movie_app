import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  List<dynamic> _movies = [];
  List<dynamic> _favorites = [];
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadFavorites();
  }

  Future<void> _loadMovies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final movies = await MovieService.getPopularMovies();
    if (mounted) {
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (mounted && doc.exists) {
        setState(() {
          _favorites = doc.data()?["favorites"] ?? [];
        });
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.trim().isEmpty) {
      _loadMovies();
      return;
    }

    setState(() => _isLoading = true);
    final results = await MovieService.searchMovies(query);

    if (mounted) {
      setState(() {
        _movies = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _addToFavorites(int movieId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      if (_favorites.contains(movieId)) {
        // Remove from favorites
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .update({
          "favorites": FieldValue.arrayRemove([movieId])
        });
        setState(() => _favorites.remove(movieId));
      } else {
        // Add to favorites
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .update({
          "favorites": FieldValue.arrayUnion([movieId])
        });
        setState(() => _favorites.add(movieId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_favorites.contains(movieId)
                ? 'Added to favorites!'
                : 'Removed from favorites'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Error updating favorites: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Discover Movies",
          style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Icons.favorite, color: Color(0xFF53fc18)),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout, color: Color(0xFF53fc18)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _isSearching = value.isNotEmpty);
                _searchMovies(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search movies...",
                hintStyle: const TextStyle(color: Colors.grey),
                labelStyle: const TextStyle(color: Color(0xFF53fc18)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF53fc18), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF53fc18), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF53fc18)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                          _loadMovies();
                        },
                        icon: const Icon(Icons.clear, color: Color(0xFF53fc18)),
                      )
                    : null,
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF53fc18)),
                ),
              ),
            )
          else if (_movies.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _isSearching ? "No movies found" : "No movies available",
                  style: const TextStyle(color: Color(0xFF53fc18), fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: _movies.map((movie) {
                  final movieId = movie["id"] ?? 0;
                  final title = movie["title"] ?? "Unknown";
                  final posterPath = movie["poster_path"];
                  final imageUrl = MovieService.getImageUrl(posterPath);
                  final isFavorited = _favorites.contains(movieId);

                  return MovieCard(
                    title: title,
                    imageUrl: imageUrl,
                    isFavorited: isFavorited,
                    onFavorite: () => _addToFavorites(movieId),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
