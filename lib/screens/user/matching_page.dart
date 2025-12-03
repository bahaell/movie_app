import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants.dart';
import '../../models/movie.dart';
import '../../services/firebase_movie_service.dart';
import 'common_movies_page.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  final FirebaseMovieService _movieService = FirebaseMovieService();
  List<Map<String, dynamic>> matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    findMatches();
  }

  Future<void> findMatches() async {
    setState(() => loading = true);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => loading = false);
      return;
    }

    final currentUserDoc =
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final existingMovieIds = await _movieService.getAllMovieIds();
    final currentFavorites = List<String>.from(currentUserDoc.data()?['favorites'] ?? [])
        .where((id) => existingMovieIds.contains(id))
        .toList();

    if (currentFavorites.isEmpty) {
      if (mounted) {
        setState(() {
          matches = [];
          loading = false;
        });
      }
      return;
    }

    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final List<Map<String, dynamic>> nextMatches = [];

    for (final doc in allUsers.docs) {
      if (doc.id == currentUser.uid) continue;
    final otherFavs = List<String>.from(doc.data()['favorites'] ?? [])
      .where((id) => existingMovieIds.contains(id))
      .toList();
    if (otherFavs.isEmpty) continue;

      final intersection =
          otherFavs.where((id) => currentFavorites.contains(id)).toList();
      final ratio = intersection.isEmpty ? 0.0 : intersection.length / otherFavs.length;

      if (ratio >= 0.75) {
        nextMatches.add({
          'userId': doc.id,
          'firstName': doc.data()['firstName'] ?? '',
          'lastName': doc.data()['lastName'] ?? '',
          'photoUrl': doc.data()['photoUrl'] ?? '',
          'ratio': ratio,
          'commonMovies': intersection,
        });
      }
    }

    nextMatches.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));

    if (!mounted) return;
    setState(() {
      matches = nextMatches;
      loading = false;
    });
  }

  Future<void> openCommonMovies(List<String> movieIds) async {
    final movies = <Movie>[];
    for (final id in movieIds) {
      final movie = await _movieService.getMovieById(id);
      if (movie != null) {
        movies.add(movie);
      }
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommonMoviesPage(movies: movies)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE_DARK,
      appBar: AppBar(
        backgroundColor: SURFACE_DARK,
        title: const Text('Matching', style: TextStyle(color: PRIMARY_GREEN)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN))
          : matches.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun utilisateur avec > 75% match 😔',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final user = matches[index];
                    final percent = (user['ratio'] * 100).toStringAsFixed(1);
                    final List<String> commonIds =
                        List<String>.from(user['commonMovies'] as List);
                    final displayName =
                        '${user['firstName']} ${user['lastName']}'.trim();
                    final fallbackName =
                        displayName.isEmpty ? 'Utilisateur ${user['userId']}' : displayName;
                    final photoUrl = user['photoUrl'] as String? ?? '';
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage:
                              photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty
                              ? Text(
                                  fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: PRIMARY_GREEN),
                                )
                              : null,
                        ),
                        title: Text(
                          fallbackName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Taux de match : $percent%',
                          style: const TextStyle(color: PRIMARY_GREEN),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_GREEN),
                          onPressed: () => openCommonMovies(commonIds),
                          child: const Text('Voir films en commun', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
