import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TmdbService {
  final String apiKey;
  TmdbService(this.apiKey);

  Future<List<MovieModel>> searchPopular({int page = 1}) async {
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&page=$page');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('TMDB error ${res.statusCode}');
    final data = jsonDecode(res.body);
    final results =
        (data['results'] as List).map((m) => MovieModel.fromMap(m)).toList();
    return results;
  }

  String imageUrl(String path) => 'https://image.tmdb.org/t/p/w500$path';
}
