import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/screens/admin/movies/admin_movie_search_page.dart';

class AdminMoviesPage extends StatefulWidget {
  const AdminMoviesPage({super.key});

  @override
  State<AdminMoviesPage> createState() => _AdminMoviesPageState();
}

class _AdminMoviesPageState extends State<AdminMoviesPage> {
  final CollectionReference moviesRef =
      FirebaseFirestore.instance.collection('movies');
  final TextEditingController tmdbIdCtrl = TextEditingController();
  bool loading = false;
  final String? tmdbApiKey = dotenv.env['TMDB_API_KEY'];

  Future<void> importFromTmdb() async {
    final id = tmdbIdCtrl.text.trim();
    if (id.isEmpty) return;
    if (tmdbApiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TMDB API Key not found!')));
      return;
    }
    setState(() => loading = true);
    try {
      // fetch from TMDB
      final url = Uri.parse(
          'https://api.themoviedb.org/3/movie/$id?api_key=$tmdbApiKey&language=fr-FR');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body);
        final docId = map['id'].toString();
        await moviesRef.doc(docId).set({
          'id': map['id'],
          'title': map['title'] ?? map['name'],
          'poster': map['poster_path'],
          'overview': map['overview'],
          'type': 'movie',
          'createdAt': FieldValue.serverTimestamp(),
        });
        tmdbIdCtrl.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Film importé')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('TMDB error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => loading = false);
  }

  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Film supprimé')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tmdbIdCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'TMDB ID',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: loading ? null : importFromTmdb,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53FC18),
                    foregroundColor: Colors.black),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Importer'),
              )
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AdminMovieSearchPage(),
              ));
            },
            icon: const Icon(Icons.search),
            label: const Text("Rechercher & Ajouter par Titre"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Films Actuellement en Base",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  moviesRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF53FC18)));
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final docId = docs[i].id;
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: ListTile(
                        leading: d['poster'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${d['poster']}',
                                width: 50,
                                fit: BoxFit.cover)
                            : null,
                        title: Text(d['title'] ?? '',
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(d['type'] ?? 'movie',
                            style: const TextStyle(color: Colors.white54)),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => deleteMovie(docId),
                          ),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminMovieSearchPage())),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53FC18),
                foregroundColor: Colors.black),
            child: const Text('Rechercher'),
          )
        ],
      ),
    );
  }
}
