import 'package:flutter/material.dart';

const String baseImg = 'https://image.tmdb.org/t/p/w500';

class SeasonDetailsPage extends StatelessWidget {
  final int tvId;
  final int seasonNumber;
  final Map<String, dynamic> seasonData;

  const SeasonDetailsPage({
    super.key,
    required this.tvId,
    required this.seasonNumber,
    required this.seasonData,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = seasonData['episodes'] as List? ?? [];
    final poster = seasonData['poster_path'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(seasonData['name'] ?? 'Season $seasonNumber',
            style: const TextStyle(color: Color(0xFF53FC18))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poster != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network('$baseImg$poster',
                    height: 250, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(height: 250, color: Colors.grey.shade800),
            const SizedBox(height: 12),
            Text(seasonData['name'] ?? '',
                style: const TextStyle(
                    color: Color(0xFF53FC18),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(seasonData['overview'] ?? '',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            const Text('Episodes',
                style: TextStyle(
                    color: Color(0xFF53FC18),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...episodes.map((ep) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ep. ${ep['episode_number']} - ${ep['name'] ?? 'Unknown'}',
                      style: const TextStyle(
                          color: Color(0xFF53FC18),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ep['overview'] ?? 'No description',
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
