import 'package:flutter/material.dart';
import '../../services/movie_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  List results = [];
  bool loading = false;

  Future<void> _onSearch(String q) async {
    setState(() => loading = true);
    results = await MovieService.search(q);
    setState(() => loading = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Search', style: TextStyle(color: Color(0xFF53fc18)))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              onSubmitted: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search movies...',
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Color(0xFF53fc18)),
              ),
            ),
          ),
          if (loading) const Expanded(child: Center(child: CircularProgressIndicator()))
          else Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final m = results[index];
                final title = m['title'] ?? m['name'] ?? 'Untitled';
                final poster = m['poster_path'];
                final imageUrl = poster != null ? MovieService.getImageUrl(poster) : '';
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/movie', arguments: m['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF53fc18), width: 2),
                    ),
                    child: Column(
                      children: [
                        Expanded(child: imageUrl.isNotEmpty ? Image.network(imageUrl, fit: BoxFit.cover) : Container(color: Colors.grey[800])),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(title, style: const TextStyle(color: Color(0xFF53fc18)), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
