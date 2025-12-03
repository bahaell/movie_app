import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants.dart';
import '../../models/movie.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/category_filter_bar.dart';
import '../../widgets/movie_horizontal_list.dart';
import '../../widgets/section_title.dart';
import '../../widgets/user_avatar_button.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().loadAll();
    });
  }

  Future<void> _refresh() async {
    await context.read<DiscoveryProvider>().loadAll(force: true);
  }

  void _openDetails(Movie movie, String heroTag) {
    Navigator.pushNamed(context, '/details', arguments: {
      'id': movie.id,
      'heroTag': heroTag,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE_DARK,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SURFACE_DARK,
        title: const Text(
          'MovieX',
          style: TextStyle(
            color: PRIMARY_GREEN,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const UserAvatarButton(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: PRIMARY_GREEN,
        onRefresh: _refresh,
        child: Consumer<DiscoveryProvider>(
          builder: (context, discovery, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildHeroSection('Now Playing', 'now', discovery.nowPlaying, discovery.loading),
                const SizedBox(height: 12),
                _buildHeroSection('Popular', 'popular', discovery.popular, discovery.loading),
                const SizedBox(height: 12),
                _buildHeroSection('Top Rated', 'top', discovery.topRated, discovery.loading),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Filters'),
                const SizedBox(height: 12),
                const CategoryFilterBar(),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Votre bibliothèque'),
                const SizedBox(height: 8),
                Consumer<MovieProvider>(
                  builder: (context, movieProvider, _) {
                    return StreamBuilder<List<Movie>>(
                      stream: movieProvider.moviesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildLibraryShimmer();
                        }
                        final movies = snapshot.data!;
                        if (movies.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Ajoutez des films via l\'admin pour les retrouver ici.',
                                style: TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return MovieHorizontalList(
                          movies,
                          heroTagBuilder: (movie, index) => 'hero_library_${movie.id}_$index',
                          onMovieTap: (movie, tag) => _openDetails(movie, tag),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    String title,
    String prefix,
    List<Movie> movies,
    bool loading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 8),
        if (loading && movies.isEmpty)
          _buildShimmerRow()
        else
          MovieHorizontalList(
            movies,
            heroTagBuilder: (movie, index) => 'hero_${prefix}_${movie.id}_$index',
            onMovieTap: (movie, tag) => _openDetails(movie, tag),
          ),
      ],
    );
  }

  Widget _buildShimmerRow() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade900,
          highlightColor: Colors.grey.shade800,
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryShimmer() {
    return SizedBox(
      height: 250,
      child: Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade900,
          highlightColor: Colors.grey.shade800,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
