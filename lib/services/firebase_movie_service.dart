import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/movie.dart';
import 'tmdb_service.dart';

class FirebaseMovieCategories {
  final List<Movie> nowPlaying;
  final List<Movie> popular;
  final List<Movie> topRated;

  const FirebaseMovieCategories({
    required this.nowPlaying,
    required this.popular,
    required this.topRated,
  });
}



class FirebaseMovieService {
  final CollectionReference moviesRef = FirebaseFirestore.instance.collection('movies');

  Stream<List<Movie>> streamMovies() {
    return moviesRef
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Movie.fromMap({
                  ...d.data() as Map<String, dynamic>,
                  'id': d.id,
                }))
            .toList());
  }

  Future<void> addMovieFromTmdb(Map<String,dynamic> tmdb) async {
    final id = tmdb['id'].toString();
    final title = (tmdb['title'] ?? tmdb['name'] ?? '').toString();
    final posterPath = tmdb['poster_path'];
    final posterUrl = posterPath != null ? '$TMDB_BASE_IMG$posterPath' : null;

    // Resolve genres: prefer explicit objects, fallback to IDs
    List<String> finalGenres = [];
    if (tmdb['genres'] != null) {
      finalGenres = (tmdb['genres'] as List)
          .map((g) => (g['name'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .cast<String>()
          .toList();
    }
    
    if (finalGenres.isEmpty && tmdb['genre_ids'] != null) {
      finalGenres = await TmdbService.resolveGenres(tmdb['genre_ids'] as List?);
    }

    await moviesRef.doc(id).set({
      'id': id,
      'title': title,
      'titleLower': title.toString().toLowerCase(),
      'poster': posterUrl ?? posterPath,
      'posterPath': posterPath,
      'posterUrl': posterUrl,
      'overview': tmdb['overview'],
      'releaseDate': tmdb['release_date'],
      'vote': tmdb['vote_average'],
      'genres': finalGenres,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
  }

  // Convenience wrapper if we already have a Movie instance.
  Future<void> addMovie(Movie m) async {
    await moviesRef.doc(m.id).set({
      ...m.toMap(),
      'titleLower': m.title.toLowerCase(),
      'genres': m.genres?.map((g) => g.trim()).toList(),
      if (m.poster != null && m.poster!.isNotEmpty)
        'posterUrl': m.poster!.startsWith('http') ? m.poster : '$TMDB_BASE_IMG${m.poster}',
    });
  }

  Future<void> removeMovie(String id) async {
    await deleteMovie(id);
  }

  Future<Movie?> getMovie(String id) async {
    final doc = await moviesRef.doc(id).get();
    if (!doc.exists) return null;
    return Movie.fromMap({...doc.data() as Map<String,dynamic>, 'id': doc.id});
  }

  Future<Movie?> getMovieById(String id) => getMovie(id);

  // Fetch all movies once (non-stream) for admin filtering UI
  Future<List<Movie>> getAllMoviesOnce() async {
    final snap = await moviesRef.get();
    return snap.docs.map((d) => Movie.fromMap({...d.data() as Map<String,dynamic>, 'id': d.id})).toList();
  }

  /// Return raw Firestore document data (with 'id') for debugging/inspection.
  Future<List<Map<String, dynamic>>> getAllMoviesRawOnce() async {
    final snap = await moviesRef.get();
    return snap.docs.map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id}).toList();
  }

  Future<Set<String>> getAllMovieIds() async {
    final snap = await moviesRef.get();
    return snap.docs.map((doc) => doc.id).toSet();
  }

  Future<FirebaseMovieCategories> getCategorizedMovies() async {
    final movies = await getAllMoviesOnce();
    final now = DateTime.now();
    final nowPlaying = _filterNowPlaying(movies, now);
    final popular = _filterPopular(movies);
    final topRated = _filterTopRated(movies);

    return FirebaseMovieCategories(
      nowPlaying: nowPlaying,
      popular: popular,
      topRated: topRated,
    );
  }

  List<Movie> _filterNowPlaying(List<Movie> movies, DateTime now) {
    final thresholdPast = now.subtract(const Duration(days: 90));
    final thresholdFuture = now.add(const Duration(days: 30));
    final filtered = movies
        .where((movie) {
          final date = _parseReleaseDate(movie.releaseDate);
          if (date == null) return false;
          return date.isAfter(thresholdPast) && date.isBefore(thresholdFuture);
        })
        .toList()
      ..sort((a, b) {
        final aDate = _parseReleaseDate(a.releaseDate);
        final bDate = _parseReleaseDate(b.releaseDate);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    if (filtered.isNotEmpty) {
      return filtered.take(20).toList();
    }

    // Fallback to most recent releases when no movie matches window
    final recent = _sortByDateDescending(movies);
    return recent.take(20).toList();
  }

  List<Movie> _filterPopular(List<Movie> movies) {
    final sorted = [...movies]
      ..sort((a, b) {
        final voteDiff = (b.vote ?? 0).compareTo(a.vote ?? 0);
        if (voteDiff != 0) return voteDiff;
        final aDate = _parseReleaseDate(a.releaseDate);
        final bDate = _parseReleaseDate(b.releaseDate);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return sorted.take(20).toList();
  }

  List<Movie> _filterTopRated(List<Movie> movies) {
    final filtered = movies
        .where((m) => (m.vote ?? 0) >= 7)
        .toList()
      ..sort((a, b) => (b.vote ?? 0).compareTo(a.vote ?? 0));
    final list = filtered.isNotEmpty ? filtered : _filterPopular(movies);
    return list.take(20).toList();
  }

  List<Movie> _sortByDateDescending(List<Movie> movies) {
    final copy = [...movies]
      ..sort((a, b) {
        final aDate = _parseReleaseDate(a.releaseDate);
        final bDate = _parseReleaseDate(b.releaseDate);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return copy;
  }

  DateTime? _parseReleaseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final lower = q.toLowerCase();

    try {
      final snap = await moviesRef
          .orderBy('titleLower')
          .startAt([lower])
          .endAt(['$lower\uf8ff'])
          .limit(30)
          .get();
      final docs = snap.docs
          .map((d) => Movie.fromMap({
                ...d.data() as Map<String, dynamic>,
                'id': d.id,
              }))
          .toList();
      if (docs.isNotEmpty) return docs;
    } catch (_) {
      // Fallback to manual filtering when index/order isn't ready
    }

    final fallbackSnap = await moviesRef.limit(200).get();
    return fallbackSnap.docs
        .map((d) => Movie.fromMap({
              ...d.data() as Map<String, dynamic>,
              'id': d.id,
            }))
        .where((movie) => movie.title.toLowerCase().contains(lower))
        .toList();
  }
}
