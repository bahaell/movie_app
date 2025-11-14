class MovieModel {
  final String id;
  final String title;
  final String posterPath;
  final String overview;

  MovieModel({required this.id, required this.title, required this.posterPath, required this.overview});

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      posterPath: map['poster_path'] ?? '',
      overview: map['overview'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
    };
  }
}
