import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_movie_service.dart';
import '../../core/constants.dart';
import '../../models/movie.dart';
import 'movie_details_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonListPage extends StatefulWidget {
  final String currentUser;
  final String otherUser;
  const CommonListPage({super.key, required this.currentUser, required this.otherUser});
  @override
  State<CommonListPage> createState() => _CommonListPageState();
}

class _CommonListPageState extends State<CommonListPage> {
  List<Movie> items = [];
  bool loading = true;
  final moviesSvc = FirebaseMovieService();

  @override
  void initState() {
    super.initState();
    loadCommon();
  }

  Future<void> loadCommon() async {
    final db = FirebaseFirestore.instance;
    final a = await db.collection('users').doc(widget.currentUser).get();
    final b = await db.collection('users').doc(widget.otherUser).get();
    final setA = Set<String>.from((a.data()?['favorites'] as List? ?? []).map((e) => e.toString()));
    final setB = Set<String>.from((b.data()?['favorites'] as List? ?? []).map((e) => e.toString()));
    final common = setA.intersection(setB).toList();
    List<Movie> res = [];
    for (var id in common) {
      final m = await moviesSvc.getMovie(id);
      if (m != null) res.add(m);
    }
    if (mounted) setState(() { items = res; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('En commun', style: TextStyle(color: PRIMARY_GREEN))),
  body: loading ? const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN)) :
  items.isEmpty ? const Center(child: Text('Aucun contenu en commun', style: TextStyle(color: PRIMARY_GREEN))) :
      ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
        final it = items[i];
        final poster = it.posterUrl.isNotEmpty ? it.posterUrl : null;
        final overview = it.overview ?? '';
        return Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: poster != null ? CachedNetworkImage(imageUrl: poster, width: 60, fit: BoxFit.cover) : null,
            title: Text(it.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(overview.length > 80 ? '${overview.substring(0,80)}...' : overview, style: const TextStyle(color: Colors.white70)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsFirestore(movieId: it.id))),
          ),
        );
      }),
    );
  }
}