import '../models/user_model.dart';

/// Calcule la similarité de Jaccard entre deux listes
/// Similarité = intersection / union
/// Valeur entre 0.0 et 1.0
double jaccardSimilarity(List<String> a, List<String> b) {
  final setA = Set<String>.from(a);
  final setB = Set<String>.from(b);
  final intersectionSize = setA.intersection(setB).length;
  final unionSize = setA.union(setB).length;
  if (unionSize == 0) return 0.0;
  return intersectionSize / unionSize;
}

/// Résultat de matching entre deux utilisateurs
class MatchResult {
  final AppUser user;
  final double similarity;
  final List<String> commonMovies;

  MatchResult({
    required this.user,
    required this.similarity,
    required this.commonMovies,
  });
}

/// Trouve les matchs pour l'utilisateur actuel
/// Retourne les utilisateurs avec une similarité >= 0.75 (75%)
List<MatchResult> findMatches(
  String currentUid,
  List<String> currentFavorites,
  List<AppUser> allUsers,
) {
  final matches = <MatchResult>[];

  for (final user in allUsers) {
    // Ignorer l'utilisateur actuel
    if (user.uid == currentUid) continue;

    // Ignorer les utilisateurs désactivés
    if (user.disabled) continue;

    // Calculer la similarité
    final similarity = jaccardSimilarity(currentFavorites, user.favorites);

    // Ajouter si la similarité est >= 0.75 (75%)
    if (similarity >= 0.75) {
      // Calculer les films en commun
      final currentSet = Set<String>.from(currentFavorites);
      final commonMovies =
          Set<String>.from(user.favorites).intersection(currentSet).toList();

      matches.add(MatchResult(
        user: user,
        similarity: similarity,
        commonMovies: commonMovies,
      ));
    }
  }

  // Trier par similarité décroissante
  matches.sort((a, b) => b.similarity.compareTo(a.similarity));

  return matches;
}
