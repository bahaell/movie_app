import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../core/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/admin_movie_provider.dart';
import 'package:provider/provider.dart';
import '../../screens/admin/admin_movie_details_page.dart';

class MovieCardAdmin extends StatelessWidget {
  final Movie? movie; // for firebase
  final Map<String,dynamic>? tmdbMap; // for tmdb preview
  final bool isTmdb;

  const MovieCardAdmin._internal({this.movie, this.tmdbMap, this.isTmdb = false, super.key});

  factory MovieCardAdmin.tmdb({required Map<String,dynamic> map, Key? key}) => MovieCardAdmin._internal(tmdbMap: map, isTmdb: true, key: key);
  factory MovieCardAdmin.firebase({required Movie movie, Key? key}) => MovieCardAdmin._internal(movie: movie, isTmdb: false, key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AdminMovieProvider>(context, listen:false);
  final title = isTmdb ? (tmdbMap!['title'] ?? tmdbMap!['name']) : movie!.title;
  final poster = isTmdb
    ? (tmdbMap!['poster_path'] != null ? '$TMDB_BASE_IMG${tmdbMap!['poster_path']}' : null)
    : (movie!.posterUrl.isNotEmpty ? movie!.posterUrl : null);
    final id = isTmdb ? tmdbMap!['id'].toString() : movie!.id;

    return Card(
      clipBehavior: Clip.hardEdge,
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: poster != null ? CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover) : Container(color: Colors.grey.shade800),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
          ),
          Row(
            children: [
              Expanded(
                child: isTmdb
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_GREEN, foregroundColor: Colors.black),
                      icon: const Icon(Icons.add),
                      label: const Text('Import'),
                      onPressed: () async {
                        await prov.addTmdbMovieToFirebase(tmdbMap!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Film importé')));
                        }
                      },
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                      onPressed: () async {
                        final idToRemove = movie!.id;
                        await prov.removeMovieFromFirebase(idToRemove);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Film supprimé')));
                        }
                      },
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminMovieDetailsPage(movieId: id)));
                },
              )
            ],
          )
        ],
      ),
    );
  }
}