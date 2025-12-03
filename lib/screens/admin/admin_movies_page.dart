import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_movie_provider.dart';
import '../../core/constants.dart';
import '../../widgets/admin/movie_card_admin.dart';

class AdminMoviesPage extends StatefulWidget {
  final bool openSearch;
  const AdminMoviesPage({super.key, this.openSearch=false});

  @override State<AdminMoviesPage> createState() => _AdminMoviesPageState();
}

class _AdminMoviesPageState extends State<AdminMoviesPage> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'new';

  @override
  void initState() {
    super.initState();
    // fetch "new" movies by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<AdminMovieProvider>(context, listen: false);
      prov.fetchTmdbNowPlaying();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AdminMovieProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search TMDB (title / id)',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.search, color: PRIMARY_GREEN),
                  ),
                  onSubmitted: (v) => prov.searchTmdb(v),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCategory == 'new' ? PRIMARY_GREEN : Colors.grey.shade800,
                  foregroundColor: _selectedCategory == 'new' ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  setState(() => _selectedCategory = 'new');
                  prov.fetchTmdbNowPlaying();
                },
                child: const Text('New'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCategory == 'popular' ? PRIMARY_GREEN : Colors.grey.shade800,
                  foregroundColor: _selectedCategory == 'popular' ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  setState(() => _selectedCategory = 'popular');
                  prov.fetchTmdbPopular();
                },
                child: const Text('Popular'),
              ),
            ]),

            const SizedBox(height: 12),

            if (prov.loading) const Expanded(child: Center(child: CircularProgressIndicator(color: PRIMARY_GREEN)))
            else Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: .65, crossAxisSpacing: 12, mainAxisSpacing: 12
                ),
                itemCount: prov.tmdbResults.length,
                itemBuilder: (_, i) => MovieCardAdmin.tmdb(map: prov.tmdbResults[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}