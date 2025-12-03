import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../models/movie.dart';
import '../../widgets/search_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SearchProvider>(context);
    final controller = TextEditingController();
    return SearchView(
      controller: controller,
      onChanged: provider.searchMovies,
      loading: provider.loading,
      results: provider.results,
      hintText: 'Search movies...',
      contentBuilder: (context, results, loading, controller) {
        if (loading) return const Center(child: CircularProgressIndicator());
        if (results.isEmpty) return const Center(child: Text('Search for a movie...', style: TextStyle(color: Colors.grey)));
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.55,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: results.length,
          itemBuilder: (_, i) {
            final Movie movie = results[i];
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/details', arguments: movie.id),
              child: Column(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(movie.posterUrl, height: 160, fit: BoxFit.cover)),
                  const SizedBox(height: 5),
                  Text(movie.title, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }
}