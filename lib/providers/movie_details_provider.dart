import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/firebase_movie_service.dart';
import '../services/tmdb_service.dart';

class MovieDetailsProvider with ChangeNotifier {
  Movie? movie;
  List<Movie> similar = [];
  List<Map<String,dynamic>> cast = [];
  final _firebase = FirebaseMovieService();

  Future<Movie?> loadMovie(String id) async {
    final firebaseMovie = await _firebase.getMovie(id);
    final tmdbData = await TmdbService.fetchMovieById(id);
    if (tmdbData != null) {
      final merged = <String, dynamic>{
        ...tmdbData,
        if (firebaseMovie != null) ...firebaseMovie.toMap(),
      };
      movie = Movie.fromMap(merged);
    } else {
      movie = firebaseMovie;
    }

    similar = (await TmdbService.getSimilarMovies(id)).map(Movie.fromMap).take(10).toList();
    cast = (await TmdbService.getCast(id)).take(10).map((c) => {
          'name': c['name'] ?? '',
          'character': c['character'] ?? '',
          'profile_path': c['profile_path'],
        }).toList();

    notifyListeners();
    return movie;
  }
}