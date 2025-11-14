import 'package:flutter/material.dart';
import '../../services/movie_service.dart';
import '../../services/tv_service.dart';
import 'movie_details.dart';
import 'tv_details.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

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
    if (q.trim().isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => loading = true);
    final movies = await MovieService.search(q);
    final tvs = await TvService.search(q);
    
    // Combine results with type tag
    final combined = <Map<String, dynamic>>[];
    combined.addAll(movies.map((m) => {...(m as Map), 'kind': 'movie'}));
    combined.addAll(tvs.map((t) => {...(t as Map), 'kind': 'tv'}));
    
    setState(() {
      results = combined;
      loading = false;
    });
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Search', style: TextStyle(color: Color(0xFF53FC18))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              onSubmitted: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search movies or TV shows...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF53FC18)),
                  onPressed: () => _onSearch(_ctrl.text),
                ),
              ),
            ),
          ),
          if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF53FC18))))
          else if (results.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _ctrl.text.isEmpty ? 'Enter a search term' : 'No results found',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final it = results[i] as Map<String, dynamic>;
                  final kind = it['kind'] as String;
                  final title = kind == 'movie' ? it['title'] ?? '' : it['name'] ?? '';
                  final poster = it['poster_path'];
                  final img = poster != null ? '$baseImg$poster' : null;
                  
                  return GestureDetector(
                    onTap: () {
                      if (kind == 'movie') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: it['id'])));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TvDetailsPage(tvId: it['id'])));
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (img != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(img, width: 60, height: 90, fit: BoxFit.cover),
                            )
                          else
                            Container(width: 60, height: 90, color: Colors.grey.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(color: Color(0xFF53FC18), fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kind.toUpperCase(),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Color(0xFF53FC18)),
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
