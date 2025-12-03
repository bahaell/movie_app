class Movie {
  final String id;
  final String title;
  final String? poster;
  final String? posterUrlStored;
  final String? overview;
  final String? releaseDate;
  final num? vote;
  final List<String>? genres;

  Movie({
    required this.id,
    required this.title,
    this.poster,
    this.posterUrlStored,
    this.overview,
    this.releaseDate,
    this.vote,
    this.genres,
  });

  factory Movie.fromMap(Map<String, dynamic> m) {
    return Movie(
      id: m['id'].toString(),
      title: m['title'] ?? m['name'] ?? '',
      poster: m['poster'] ?? m['poster_path'],
      posterUrlStored: m['posterUrl'],
      overview: m['overview'] ?? '',
      releaseDate: m['releaseDate'] ?? m['release_date'],
      vote: m['vote'] ?? m['vote_average'],
    genres: (m['genres'] as List?)
      ?.map((e) => e is Map ? (e['name'] ?? '').toString() : e.toString())
      .map((s) => s.trim())
      .where((e) => e.isNotEmpty)
      .cast<String>()
      .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleLower': title.toLowerCase(),
      'poster': poster,
      'posterUrl': posterUrlStored ?? posterUrl,
      'overview': overview,
      'releaseDate': releaseDate,
      'vote': vote,
  'genres': genres?.map((g) => g.trim()).toList(),
    };
  }

  // Convenience computed URLs for UI widgets
  String get posterUrl {
    if (posterUrlStored != null && posterUrlStored!.isNotEmpty) return posterUrlStored!;
    if (poster == null || poster!.isEmpty) return '';
    if (poster!.startsWith('http')) return poster!;
    return 'https://image.tmdb.org/t/p/w500$poster';
  }
  String get backdropUrl => posterUrl; // Fallback until backdrop field added
}

