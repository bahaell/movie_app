import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tmdb_service.dart';
import '../models/movie_model.dart';
import '../widgets/movie_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TmdbService _tmdbService;
  late Future<List<MovieModel>> _popularMovies;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with your actual TMDB API key
    _tmdbService = TmdbService('YOUR_TMDB_API_KEY');
    _popularMovies = _tmdbService.searchPopular();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // TODO: Navigate to playlist screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              // TODO: Navigate to match screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _popularMovies = _tmdbService.searchPopular();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MovieModel>>(
              future: _popularMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No movies found'));
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MovieTile(
                        movie: snapshot.data![index],
                        tmdbService: _tmdbService,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
