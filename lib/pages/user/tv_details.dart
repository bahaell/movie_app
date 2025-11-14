import 'package:flutter/material.dart';
import '../../services/tv_service.dart';
import '../../services/movie_service.dart';

class TvDetailsPage extends StatefulWidget {
  final int tvId;
  const TvDetailsPage({super.key, required this.tvId});

  @override
  State<TvDetailsPage> createState() => _TvDetailsPageState();
}

class _TvDetailsPageState extends State<TvDetailsPage> {
  Map details = {};
  List similar = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    details = await TvService.details(widget.tvId);
    similar = await TvService.similar(widget.tvId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(details['name'] ?? 'Details', style: const TextStyle(color: Color(0xFF53fc18))),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details['name'] ?? '', style: const TextStyle(color: Color(0xFF53fc18), fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Seasons: ${details['number_of_seasons'] ?? '-'}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(details['overview'] ?? '', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text('Similar TV Shows', style: TextStyle(color: Color(0xFF53fc18), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: similar.length,
                      itemBuilder: (context, index) {
                        final s = similar[index];
                        final title = s['name'] ?? '';
                        final poster = s['poster_path'];
                        final img = poster != null ? MovieService.getImageUrl(poster) : '';
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: img.isNotEmpty
                                    ? Image.network(img, height: 200, width: 140, fit: BoxFit.cover)
                                    : Container(height: 200, width: 140, color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 6),
                              Text(title, style: const TextStyle(color: Color(0xFF53fc18)), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
