import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../services/firebase_movie_service.dart';
import '../services/watchlist_service.dart';
import '../models/movie.dart';
import '../core/constants.dart';

class AdminMovieProvider with ChangeNotifier {
  final FirebaseMovieService _firebase = FirebaseMovieService();

  bool loading = false;
  List<Map<String,dynamic>> tmdbResults = []; // raw TMDB maps
  List<Movie> firebaseMovies = [];
  List<String> _availableGenres = DEFAULT_GENRES;

  List<String> get availableGenres => _availableGenres;

  String currentQuery = '';
  String currentSort = 'popular'; // can be 'popular', 'top_rated', 'latest'
  String currentGenre = '';
  double? minRating;
  int? minYear;

  AdminMovieProvider() {
    loadFirebaseMovies();
  }

  Future<void> searchTmdb(String q) async {
    if (q.trim().isEmpty) return;
    loading = true; notifyListeners();
    tmdbResults = await TmdbService.searchMovies(q);
    currentQuery = q;
    loading = false; notifyListeners();
  }

  Future<void> fetchTmdbPopular() async {
    loading = true; notifyListeners();
    tmdbResults = await TmdbService.getPopularMovies();
    loading = false; notifyListeners();
  }

  Future<void> fetchTmdbNowPlaying() async {
    loading = true; notifyListeners();
    tmdbResults = await TmdbService.getNowPlayingMovies();
    loading = false; notifyListeners();
  }

  Future<void> addTmdbMovieToFirebase(Map<String,dynamic> tmdb) async {
    await _firebase.addMovieFromTmdb(tmdb);
    await loadFirebaseMovies();
  }

  Future<void> removeMovieFromFirebase(String id) async {
    await _firebase.deleteMovie(id);
    await WatchlistService.purgeMovieFromAllUsers(id);
    await loadFirebaseMovies();
  }

  Future<void> loadFirebaseMovies() async {
    loading = true; notifyListeners();
    firebaseMovies = await _firebase.getAllMoviesOnce();
    
    // Recalculate available genres
    final Map<String, String> normalized = {};
    for (final m in firebaseMovies) {
      final gs = m.genres ?? [];
      for (final g in gs) {
        final s = g.trim();
        if (s.isNotEmpty) normalized[s.toLowerCase()] = s;
      }
    }
    if (normalized.isNotEmpty) {
      _availableGenres = normalized.values.toList()..sort();
    } else {
      _availableGenres = DEFAULT_GENRES;
    }

    // In debug mode, log raw Firestore documents to help diagnose genre shapes
    assert(() {
      _debugLogRawMovies();
      return true;
    }());
    loading = false; notifyListeners();
  }

  // Debug helper prints first few raw documents to console (only in debug via assert)
  Future<void> _debugLogRawMovies() async {
    try {
      final raws = await _firebase.getAllMoviesRawOnce();
      for (var i = 0; i < (raws.length < 10 ? raws.length : 10); i++) {
        final r = raws[i];
        // Use debugPrint to avoid truncation in some consoles
        debugPrint('RAW MOVIE [${r['id']}] title=${r['title']} genres=${r['genres']?.runtimeType} => ${r['genres']}');
      }
    } catch (e) {
      debugPrint('Failed to fetch raw movies for debug: $e');
    }
  }

  // Filtering locally for admin list — single clean predicate to avoid duplication
  List<Movie> filteredFirebaseMovies() {
    String normalize(String s) => s.toLowerCase().trim();

    bool matches(Movie m) {
      // Genre
      if (currentGenre.isNotEmpty) {
        final target = normalize(currentGenre);
        final gs = (m.genres ?? []).map((g) => normalize(g)).toList();
        bool found = false;
        for (final g in gs) {
          if (g == target || g.contains(target)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }

      // Rating
      if (minRating != null) {
        if ((m.vote ?? 0) < minRating!) return false;
      }

      // Year
      if (minYear != null) {
        final rd = m.releaseDate;
        if (rd == null || rd.isEmpty) return false;

        int? y;
        if (rd.length >= 4) {
          y = int.tryParse(rd.substring(0, 4));
        }
        if (y == null) {
          try {
            final d = DateTime.tryParse(rd);
            if (d != null) y = d.year;
          } catch (_) {}
        }
        if (y == null || y < minYear!) return false;
      }

      return true;
    }

    return firebaseMovies.where(matches).toList();
  }

  void setGenre(String g) { currentGenre = g; notifyListeners(); }
  void setMinRating(double? r) { minRating = r; notifyListeners(); }
  void setMinYear(int? y) { minYear = y; notifyListeners(); }
}