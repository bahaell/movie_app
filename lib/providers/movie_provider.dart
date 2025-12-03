import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/firebase_movie_service.dart';
import '../core/constants.dart';

class MovieProvider with ChangeNotifier {
  final FirebaseMovieService _svc = FirebaseMovieService();
  String _genreFilter = '';
  double? _minRating;
  int? _minYear;
  String? _titleBucket;

  List<String> availableGenres = DEFAULT_GENRES;

  MovieProvider() {
    _loadAvailableGenres();
  }

  Future<void> _loadAvailableGenres() async {
    try {
      final movies = await _svc.getAllMoviesOnce();
      final Map<String, String> normalized = {}; // key=lower->value=original trimmed
      for (final m in movies) {
        final gs = m.genres ?? [];
        for (final g in gs) {
          final s = g.trim();
          if (s.isNotEmpty) normalized[s.toLowerCase()] = s;
        }
      }
      if (normalized.isNotEmpty) {
        availableGenres = normalized.values.toList()..sort();
      }
      notifyListeners();
    } catch (_) {
      // keep defaults on error
    }
  }

  void setGenreFilter(String g) { _genreFilter = g; notifyListeners(); }
  void clearGenre() { _genreFilter = ''; notifyListeners(); }
  void setMinRating(double? r) { _minRating = r; notifyListeners(); }
  void setMinYear(int? y) { _minYear = y; notifyListeners(); }
  void setTitleBucket(String? bucket) { _titleBucket = bucket; notifyListeners(); }
  void resetFilters() { _genreFilter=''; _minRating=null; _minYear=null; _titleBucket=null; notifyListeners(); }

  Stream<List<Movie>> moviesStream() {
    // Apply client-side filtering in one place with a clear predicate.
    return _svc.streamMovies().map((list) {
      String normalize(String s) => s.toLowerCase().trim();

      bool matches(Movie m) {
        // Genre
        if (_genreFilter.isNotEmpty) {
          final target = normalize(_genreFilter);
          final gs = (m.genres ?? []).map((g) => normalize(g)).toList();
          // Use explicit loop for safer matching
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
        if (_minRating != null) {
          final vote = (m.vote ?? 0).toDouble();
          if (vote < _minRating!) return false;
        }

        // Year
        if (_minYear != null) {
          final rd = m.releaseDate;
          if (rd == null || rd.isEmpty) return false;
          
          int? y;
          // Try simple substring first
          if (rd.length >= 4) {
            y = int.tryParse(rd.substring(0, 4));
          }
          // Fallback to full parsing if simple substring fails or is ambiguous
          if (y == null) {
             try {
               final d = DateTime.tryParse(rd);
               if (d != null) y = d.year;
             } catch (_) {}
          }
          
          if (y == null || y < _minYear!) return false;
        }

        // Title bucket
        if (_titleBucket != null && _titleBucket!.isNotEmpty) {
          if (m.title.isEmpty) return false;
          final first = m.title[0].toUpperCase();
          if (_titleBucket == 'A-M') {
            if (!(first.compareTo('N') < 0)) return false;
          } else {
            if (!(first.compareTo('N') >= 0)) return false;
          }
        }

        return true;
      }

      return list.where(matches).toList();
    });
  }

  FirebaseMovieService get service => _svc;
  String get genreFilter => _genreFilter;
  double? get minRating => _minRating;
  int? get minYear => _minYear;
  String? get titleBucket => _titleBucket;
}
