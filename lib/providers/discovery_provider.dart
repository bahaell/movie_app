import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/firebase_movie_service.dart';

class DiscoveryProvider with ChangeNotifier {
  final FirebaseMovieService _firebase = FirebaseMovieService();
  List<Movie> nowPlaying = [];
  List<Movie> popular = [];
  List<Movie> topRated = [];
  bool loading = false;
  String? error;

  Future<void> loadAll({bool force = false}) async {
    if (loading && !force) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final categories = await _firebase.getCategorizedMovies();
      nowPlaying = categories.nowPlaying;
      popular = categories.popular;
      topRated = categories.topRated;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
