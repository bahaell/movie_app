import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TvService {
  // Read TMDB API key from environment; fallback provided
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? "00498c90aa03a7dbf2659cca75f6a735";
  static const base = "https://api.themoviedb.org/3";
  static const imageBase = "https://image.tmdb.org/t/p/w500";

  static Future<List> onAir({int page = 1}) async =>
      _get("$base/tv/on_the_air?api_key=$apiKey&language=fr-FR&page=$page");

  static Future<List> popular({int page = 1}) async =>
      _get("$base/tv/popular?api_key=$apiKey&language=fr-FR&page=$page");

  static Future<List> topRated({int page = 1}) async =>
      _get("$base/tv/top_rated?api_key=$apiKey&language=fr-FR&page=$page");

  static Future<Map> details(int id) async =>
      _getMap("$base/tv/$id?api_key=$apiKey&language=fr-FR");

  static Future<List> similar(int id) async =>
      _get("$base/tv/$id/similar?api_key=$apiKey&language=fr-FR");

  static Future<Map> seasonDetails(int id, int season) async =>
      _getMap("$base/tv/$id/season/$season?api_key=$apiKey&language=fr-FR");

  static Future<List> search(String q, {int page = 1}) async =>
      _get("$base/search/tv?api_key=$apiKey&query=${Uri.encodeComponent(q)}&language=fr-FR&page=$page");

  // Helpers
  static Future<List> _get(String url, {String listKey = "results"}) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return (json[listKey] as List?) ?? [];
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  static Future<Map> _getMap(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // ignore
    }
    return {};
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "$imageBase/null";
    return "$imageBase$path";
  }
}
