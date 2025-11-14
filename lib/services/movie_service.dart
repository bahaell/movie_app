import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieService {
  // Read TMDB API key from environment; fall back to the embedded key if not provided.
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? "00498c90aa03a7dbf2659cca75f6a735";
  static const baseUrl = "https://api.themoviedb.org/3";
  static const imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  static Future<List<dynamic>> getPopularMovies({int page = 1}) async {
    try {
      final url = Uri.parse(
        "$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=$page",
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["results"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching popular movies: $e");
      return [];
    }
  }

  static Future<List<dynamic>> searchMovies(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final url = Uri.parse(
        "$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}&language=en-US",
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["results"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error searching movies: $e");
      return [];
    }
  }

  static String getImageUrl(String? posterPath) {
    if (posterPath == null || posterPath.isEmpty) {
      return "$imageBaseUrl/null";
    }
    return "$imageBaseUrl$posterPath";
  }

  // Compatibility helpers used across the app
  static Future<List<dynamic>> nowPlaying({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&language=en-US&page=$page');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      print('Error fetching now playing: $e');
    }
    return [];
  }

  static Future<List<dynamic>> topRated({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&language=en-US&page=$page');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      print('Error fetching top rated: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> details(int id) async {
    try {
      final url = Uri.parse('$baseUrl/movie/$id?api_key=$apiKey&language=en-US');
      final res = await http.get(url);
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching movie details: $e');
    }
    return {};
  }

  static Future<List<dynamic>> cast(int id) async {
    try {
      final url = Uri.parse('$baseUrl/movie/$id/credits?api_key=$apiKey&language=en-US');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['cast'] ?? [];
      }
    } catch (e) {
      print('Error fetching cast: $e');
    }
    return [];
  }

  static Future<List<dynamic>> reviews(int id) async {
    try {
      final url = Uri.parse('$baseUrl/movie/$id/reviews?api_key=$apiKey&language=en-US');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
    return [];
  }

  static Future<List<dynamic>> similar(int id) async {
    try {
      final url = Uri.parse('$baseUrl/movie/$id/similar?api_key=$apiKey&language=en-US');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      print('Error fetching similar movies: $e');
    }
    return [];
  }

  static Future<List<dynamic>> search(String q, {int page = 1}) async {
    return await searchMovies(q);
  }
}
