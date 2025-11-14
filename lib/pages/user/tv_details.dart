import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/tv_service.dart';
import '../../services/watchlist_service.dart';
import 'season_details.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class TvDetailsPage extends StatefulWidget {
  final int tvId;
  const TvDetailsPage({super.key, required this.tvId});

  @override
  State<TvDetailsPage> createState() => _TvDetailsPageState();
}

class _TvDetailsPageState extends State<TvDetailsPage> {
  Map<String, dynamic>? details;
  List cast = [];
  List similar = [];
  bool loading = true;
  bool isFav = false;
  String favTag = '';

  @override
  void initState() {
    super.initState();
    favTag = 'tv_${widget.tvId}';
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final d = await TvService.details(widget.tvId);
    final c = await TvService.credits(widget.tvId);
    final s = await TvService.similar(widget.tvId);

    // check watchlist
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final wl = await WatchlistService.getWatchlistOnce(uid);
      final fav = wl.contains(favTag);
      setState(() => isFav = fav);
    } catch (e) {
      print('Error loading watchlist: $e');
    }

    setState(() {
      details = d as Map<String, dynamic>?;
      cast = c;
      similar = s;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || details == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF53FC18))),
      );
    }

    final poster = details!['poster_path'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(details!['name'] ?? '', style: const TextStyle(color: Color(0xFF53FC18))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Hero
            if (poster != null)
              Hero(
                tag: favTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network('$baseImg$poster', height: 300, width: double.infinity, fit: BoxFit.cover),
                ),
              )
            else
              Container(height: 300, color: Colors.grey.shade800),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(details!['name'] ?? '', style: const TextStyle(color: Color(0xFF53FC18), fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      if (!isFav) {
                        await WatchlistService.addToWatchlist(widget.tvId, 'tv');
                      } else {
                        await WatchlistService.removeFromWatchlist(widget.tvId, 'tv');
                      }
                      final wl = await WatchlistService.getWatchlistOnce(uid);
                      setState(() => isFav = wl.contains(favTag));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFF53FC18)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(details!['overview'] ?? '', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            if (cast.isNotEmpty) ...[
              const Text('Cast', style: TextStyle(color: Color(0xFF53FC18), fontSize: 18)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cast.length,
                  itemBuilder: (context, i) {
                    final actor = cast[i];
                    final img = actor['profile_path'] != null ? '$baseImg${actor['profile_path']}' : null;
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img != null
                                ? Image.network(img, height: 80, fit: BoxFit.cover, width: 90)
                                : Container(height: 80, color: Colors.grey.shade800, width: 90),
                          ),
                          const SizedBox(height: 6),
                          Text(actor['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text('Seasons', style: TextStyle(color: Color(0xFF53FC18), fontSize: 18)),
            const SizedBox(height: 8),
            ...((details!['seasons'] as List? ?? []).map((season) {
              return GestureDetector(
                onTap: () async {
                  final map = await TvService.seasonDetails(widget.tvId, season['season_number']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeasonDetailsPage(tvId: widget.tvId, seasonNumber: season['season_number'], seasonData: map as Map<String, dynamic>),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      if (season['poster_path'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network('$baseImg${season['poster_path']}', width: 50, height: 75, fit: BoxFit.cover),
                        )
                      else
                        Container(width: 50, height: 75, color: Colors.grey.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(season['name'] ?? '', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('Episodes: ${season['episode_count'] ?? '?'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Color(0xFF53FC18)),
                    ],
                  ),
                ),
              );
            })).toList(),
            const SizedBox(height: 12),
            if (similar.isNotEmpty) ...[
              const Text('Similar', style: TextStyle(color: Color(0xFF53FC18), fontSize: 18)),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  itemBuilder: (context, i) {
                    final it = similar[i];
                    final img = it['poster_path'] != null ? '$baseImg${it['poster_path']}' : null;
                    return GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TvDetailsPage(tvId: it['id']))),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: img != null
                                  ? Image.network(img, height: 140, fit: BoxFit.cover, width: 110)
                                  : Container(height: 140, color: Colors.grey.shade800, width: 110),
                            ),
                            const SizedBox(height: 6),
                            Text(it['name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
