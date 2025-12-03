import 'package:flutter/material.dart';
import '../services/firebase_movie_service.dart';
import '../services/tmdb_service.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseMovieService _svc = FirebaseMovieService();

  Future<List> searchTmdb(String q) => TmdbService.searchMovies(q);
  Future<void> importMovie(Map<String,dynamic> tmdb) => _svc.addMovieFromTmdb(tmdb);
  Future<void> deleteMovie(String id) => _svc.deleteMovie(id);
}
