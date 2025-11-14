import 'package:flutter/material.dart';
import '../../services/tv_service.dart';

class SeasonDetailsPage extends StatefulWidget {
  final int tvId;
  final int seasonNumber;
  const SeasonDetailsPage({super.key, required this.tvId, required this.seasonNumber});

  @override
  State<SeasonDetailsPage> createState() => _SeasonDetailsPageState();
}

class _SeasonDetailsPageState extends State<SeasonDetailsPage> {
  Map season = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    season = await TvService.seasonDetails(widget.tvId, widget.seasonNumber);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(season['name'] ?? 'Season', style: const TextStyle(color: Color(0xFF53fc18)))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (season['poster_path'] != null) Image.network(TvService.getImageUrl(season['poster_path'])),
                const SizedBox(height: 12),
                Text(season['overview'] ?? '', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                Text('Episodes: ${((season['episodes'] ?? []) as List).length}', style: const TextStyle(color: Color(0xFF53fc18))),
                const SizedBox(height: 12),
                ...((season['episodes'] ?? []) as List).map((e) => ListTile(
                      title: Text(e['name'] ?? '', style: const TextStyle(color: Color(0xFF53fc18))),
                      subtitle: Text(e['overview'] ?? '', style: const TextStyle(color: Colors.white)),
                    ))
              ]),
            ),
    );
  }
}
