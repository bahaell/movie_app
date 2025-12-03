import 'dart:convert';
import 'package:http/http.dart' as http;

const String tmdbApiKey = '00498c90aa03a7dbf2659cca75f6a735';
const String tmdbBase = 'https://api.themoviedb.org/3';

class TmdbService {
  static Future<List<Map<String, dynamic>>> _fetchList(String path, {Map<String, String>? params}) async {
    final qp = {
      'api_key': tmdbApiKey,
      'language': 'fr-FR',
      ...?params,
    };
    final uri = Uri.https('api.themoviedb.org', '/3/$path', qp);
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body);
    return (decoded['results'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> searchMovies(String query) {
    return _fetchList('search/movie', params: {'query': query});
  }

  static Future<List<Map<String, dynamic>>> getPopularMovies() {
    return _fetchList('movie/popular');
  }

  static Future<List<Map<String, dynamic>>> getTopRatedMovies() {
    return _fetchList('movie/top_rated');
  }

  static Future<List<Map<String, dynamic>>> getNowPlayingMovies() {
    return _fetchList('movie/now_playing');
  }

  static Future<List<Map<String, dynamic>>> getSimilarMovies(String movieId) {
    return _fetchList('movie/$movieId/similar');
  }

  static Future<Map<String, dynamic>?> fetchMovieById(String id) async {
    final uri = Uri.https('api.themoviedb.org', '/3/movie/$id', {
      'api_key': tmdbApiKey,
      'language': 'fr-FR',
      'append_to_response': 'credits',
    });
    final r = await http.get(uri);
    if (r.statusCode != 200) return null;
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getCast(String movieId) async {
    final uri = Uri.https('api.themoviedb.org', '/3/movie/$movieId/credits', {
      'api_key': tmdbApiKey,
      'language': 'fr-FR',
    });
    final r = await http.get(uri);
    if (r.statusCode != 200) return [];
    final body = jsonDecode(r.body);
    return (body['cast'] as List? ?? []).cast<Map<String, dynamic>>();
  }
  static Map<int, String> _genreCache = {};

  static Future<void> fetchGenres() async {
    if (_genreCache.isNotEmpty) return;
    final uri = Uri.https('api.themoviedb.org', '/3/genre/movie/list', {
      'api_key': tmdbApiKey,
      'language': 'fr-FR',
    });
    try {
      final r = await http.get(uri);
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final list = data['genres'] as List? ?? [];
        for (final item in list) {
          _genreCache[item['id']] = item['name'];
        }
      }
    } catch (_) {}
  }

  static Future<List<String>> resolveGenres(List<dynamic>? ids) async {
    if (ids == null || ids.isEmpty) return [];
    if (_genreCache.isEmpty) await fetchGenres();
    final names = <String>[];
    for (final id in ids) {
      if (id is int && _genreCache.containsKey(id)) {
        names.add(_genreCache[id]!);
      }
    }
    return names;
  }
}
