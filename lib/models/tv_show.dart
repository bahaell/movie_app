class TvShow {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final List<int>? genreIds;
  final int? numberOfSeasons;

  TvShow({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.genreIds,
    this.numberOfSeasons,
  });

  factory TvShow.fromMap(Map<String, dynamic> map) {
    return TvShow(
      id: map['id'] ?? 0,
      name: map['name'] ?? map['title'] ?? 'Unknown',
      overview: map['overview'],
      posterPath: map['poster_path'],
      backdropPath: map['backdrop_path'],
      voteAverage: (map['vote_average'] is num) ? (map['vote_average'] as num).toDouble() : null,
      genreIds: (map['genre_ids'] as List<dynamic>?)?.cast<int>(),
      numberOfSeasons: map['number_of_seasons'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'genre_ids': genreIds,
        'number_of_seasons': numberOfSeasons,
      };
}
