class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? runtime;
  final List<int>? genreIds;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.runtime,
    this.genreIds,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? map['name'] ?? 'Unknown',
      overview: map['overview'],
      posterPath: map['poster_path'],
      backdropPath: map['backdrop_path'],
      voteAverage: (map['vote_average'] is num)
          ? (map['vote_average'] as num).toDouble()
          : null,
      runtime: map['runtime'],
      genreIds: (map['genre_ids'] as List<dynamic>?)?.cast<int>(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'runtime': runtime,
        'genre_ids': genreIds,
      };
}
