import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminMovieSearchPage extends StatefulWidget {
  const AdminMovieSearchPage({super.key});

  @override
  State<AdminMovieSearchPage> createState() => _AdminMovieSearchPageState();
}

class _AdminMovieSearchPageState extends State<AdminMovieSearchPage> {
  final TextEditingController searchCtrl = TextEditingController();
  List results = [];
  bool loading = false;

  final String? apiKey = dotenv.env['TMDB_API_KEY'];

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) return;
     if (apiKey == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("TMDB API Key not found!")),
      );
      return;
    }

    setState(() => loading = true);

    final url = Uri.parse(
        "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query");

    final response = await http.get(url);

    setState(() {
      loading = false;
      if (response.statusCode == 200) {
        results = jsonDecode(response.body)["results"];
      } else {
        results = [];
      }
    });
  }

  Future<void> addMovieToFirestore(dynamic movie) async {
    await FirebaseFirestore.instance
        .collection("movies")
        .doc(movie["id"].toString())
        .set({
      "id": movie["id"],
      "title": movie["title"],
      "poster_path": movie["poster_path"],
      "overview": movie["overview"],
      "release_date": movie["release_date"],
      "vote_average": movie["vote_average"],
      "type": "movie",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Film ajouté à Firestore ✔")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Ajouter un film (Recherche TMDB)"),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Chercher un film…",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.greenAccent),
                  onPressed: () => searchMovies(searchCtrl.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, i) {
                final movie = results[i];

                return ListTile(
                  leading: movie["poster_path"] != null
                      ? Image.network(
                          "https://image.tmdb.org/t/p/w200${movie["poster_path"]}")
                      : const Icon(Icons.movie),
                  title: Text(
                    movie["title"],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "⭐ ${movie["vote_average"]}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Colors.greenAccent),
                    onPressed: () => addMovieToFirestore(movie),
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
