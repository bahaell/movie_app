import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class SearchProvider with ChangeNotifier {
  final _ref = FirebaseFirestore.instance.collection('movies');
  List<Movie> results = [];
  bool loading = false;

  Future<void> searchMovies(String q) async {
    if (q.isEmpty) { results = []; notifyListeners(); return; }
    loading = true; notifyListeners();
    final snap = await _ref
        .where('title', isGreaterThanOrEqualTo: q)
        .where('title', isLessThanOrEqualTo: '$q\uf8ff')
        .get();
    final firebaseResults = snap.docs.map((d) => Movie.fromMap({...d.data(), 'id': d.id})).toList();
    if (firebaseResults.isNotEmpty) {
      results = firebaseResults;
    } else {
      final tmdb = await TmdbService.searchMovies(q);
      results = tmdb.map(Movie.fromMap).toList();
    }
    loading = false; notifyListeners();
  }
}