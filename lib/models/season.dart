class Season {
  final int seasonNumber;
  final String? name;
  final String? overview;
  final String? posterPath;
  final int? episodeCount;

  Season({
    required this.seasonNumber,
    this.name,
    this.overview,
    this.posterPath,
    this.episodeCount,
  });

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      seasonNumber: map['season_number'] ?? 0,
      name: map['name'],
      overview: map['overview'],
      posterPath: map['poster_path'],
      episodeCount: map['episode_count'],
    );
  }

  Map<String, dynamic> toMap() => {
        'season_number': seasonNumber,
        'name': name,
        'overview': overview,
        'poster_path': posterPath,
        'episode_count': episodeCount,
      };
}
