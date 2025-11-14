import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../services/tv_service.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/tv_card.dart';
import '../../widgets/section_title.dart';

class HomeUserPage extends StatefulWidget {
  const HomeUserPage({super.key});

  @override
  State<HomeUserPage> createState() => _HomeUserPageState();
}

class _HomeUserPageState extends State<HomeUserPage> {
  List popularMovies = [];
  List nowPlaying = [];
  List topRatedMovies = [];

  List onAirTv = [];
  List popularTv = [];
  List topRatedTv = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    popularMovies = await MovieService.getPopularMovies();
    nowPlaying = await MovieService.nowPlaying();
    topRatedMovies = await MovieService.topRated();

    onAirTv = await TvService.onAir();
    popularTv = await TvService.popular();
    topRatedTv = await TvService.topRated();

    setState(() => loading = false);
  }

  Widget _buildHorizontalList(List items, bool isMovie) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final title = isMovie ? (item['title'] ?? 'Untitled') : (item['name'] ?? 'Untitled');
          final poster = item['poster_path'];
          final imageUrl = poster != null ? (MovieService.getImageUrl(poster)) : '';

          if (isMovie) {
            return MovieCard(
              title: title,
              imageUrl: imageUrl,
              onFavorite: () {},
            );
          }

          return TvCard(
            name: title,
            imageUrl: imageUrl,
            onTap: () {},
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
        title: const Text('Home', style: TextStyle(color: Color(0xFF53fc18))),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search, color: Color(0xFF53fc18)),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            icon: const Icon(Icons.favorite, color: Color(0xFF53fc18)),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
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
                ],
              ),
            ),
    );
  }
}
