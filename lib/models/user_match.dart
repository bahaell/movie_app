/// Représente une correspondance entre deux utilisateurs basée sur la similarité des watchlists
class UserMatch {
  final String userId;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final double similarity; // Pourcentage (0-100)
  final int commonItems; // Nombre d'éléments en commun

  UserMatch({
    required this.userId,
    this.userDisplayName,
    this.userPhotoUrl,
    required this.similarity,
    required this.commonItems,
  });

  /// Conversion en JSON pour stockage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'similarity': similarity,
      'commonItems': commonItems,
    };
  }

  /// Création depuis JSON
  factory UserMatch.fromJson(Map<String, dynamic> json) {
    return UserMatch(
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String?,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      similarity: (json['similarity'] as num).toDouble(),
      commonItems: json['commonItems'] as int,
    );
  }

  @override
  String toString() =>
      'UserMatch(userId: $userId, similarity: ${similarity.toStringAsFixed(1)}%, commonItems: $commonItems)';
}
