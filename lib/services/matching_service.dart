import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_match.dart';

class MatchingService {
  static const double minSimilarityThreshold = 75.0;

  /// Calcule la similarité de Jaccard entre deux ensembles
  /// similarité = (intersection / union) * 100
  static double _calculateJaccardSimilarity(Set<String> setA, Set<String> setB) {
    if (setA.isEmpty && setB.isEmpty) return 100.0;
    if (setA.isEmpty || setB.isEmpty) return 0.0;

    final intersection = setA.intersection(setB);
    final union = setA.union(setB);

    if (union.isEmpty) return 0.0;

    return (intersection.length / union.length) * 100.0;
  }

  /// Récupère toutes les watchlists depuis Firestore et calcule les matches
  /// Retourne une liste triée par similarité décroissante (meilleur match d'abord)
  static Future<List<UserMatch>> calculateMatches(
    String currentUserId, {
    double threshold = minSimilarityThreshold,
  }) async {
    try {
      final db = FirebaseFirestore.instance;

      // 1) Récupérer la watchlist de l'utilisateur courant
      final currentUserDoc = await db.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) {
        print('Current user document not found: $currentUserId');
        return [];
      }

      final currentUserData = currentUserDoc.data() ?? {};
      final currentWatchlist = Set<String>.from(
        (currentUserData['favorites'] as List?)?.cast<String>() ?? [],
      );

      print('Current user watchlist: $currentWatchlist');

      if (currentWatchlist.isEmpty) {
        print('Current user has no favorites');
        return [];
      }

      // 2) Récupérer tous les utilisateurs
      final usersSnapshot = await db.collection('users').get();
      List<UserMatch> matches = [];

      // 3) Comparer avec chaque utilisateur
      for (final userDoc in usersSnapshot.docs) {
        final uid = userDoc.id;

        // Ignorer l'utilisateur actuel
        if (uid == currentUserId) continue;

        final userData = userDoc.data();
        final otherWatchlist = Set<String>.from(
          (userData['favorites'] as List?)?.cast<String>() ?? [],
        );

        // Ignorer les utilisateurs sans watchlist
        if (otherWatchlist.isEmpty) continue;

        // Calculer la similarité Jaccard
        final similarity = _calculateJaccardSimilarity(currentWatchlist, otherWatchlist);
        final intersection = currentWatchlist.intersection(otherWatchlist).length;

        print('User $uid similarity: ${similarity.toStringAsFixed(1)}% (common: $intersection)');

        // Ajouter si similarité >= threshold
        if (similarity >= threshold) {
          matches.add(UserMatch(
            userId: uid,
            userDisplayName: userData['firstName'] ?? 'Unknown',
            userPhotoUrl: userData['photoUrl'],
            similarity: similarity,
            commonItems: intersection,
          ));
        }
      }

      // 4) Trier par similarité décroissante (meilleur match d'abord)
      matches.sort((a, b) => b.similarity.compareTo(a.similarity));

      print('Found ${matches.length} matches with similarity >= $threshold%');
      return matches;
    } catch (e) {
      print('Error calculating matches: $e');
      rethrow;
    }
  }

  /// Récupère les éléments communs entre deux utilisateurs
  static Future<Set<String>> getCommonItems(
    String userId1,
    String userId2,
  ) async {
    try {
      final db = FirebaseFirestore.instance;

      final user1Doc = await db.collection('users').doc(userId1).get();
      final user2Doc = await db.collection('users').doc(userId2).get();

      final watchlist1 = Set<String>.from(
        (user1Doc.data()?['favorites'] as List?)?.cast<String>() ?? [],
      );

      final watchlist2 = Set<String>.from(
        (user2Doc.data()?['favorites'] as List?)?.cast<String>() ?? [],
      );

      return watchlist1.intersection(watchlist2);
    } catch (e) {
      print('Error getting common items: $e');
      return {};
    }
  }

  /// Récupère les informations complètes d'un utilisateur pour affichage
  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
}
