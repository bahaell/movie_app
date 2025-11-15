import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_match.dart';
import 'movie_service.dart';
import 'tv_service.dart';

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

  /// Récupère les détails TMDB d'un item (movie ou tv) à partir de son ID formaté
  /// Format attendu: "movie_550" ou "tv_1256"
  static Future<Map<String, dynamic>> getItemDetailsFromTMDB(String itemId) async {
    try {
      final parts = itemId.split('_');
      if (parts.length != 2) {
        print('Invalid item ID format: $itemId');
        return {};
      }

      final kind = parts[0]; // "movie" ou "tv"
      final id = parts[1];

      if (kind == 'movie') {
        return await MovieService.details(int.parse(id));
      } else if (kind == 'tv') {
        return await TvService.details(int.parse(id));
      }

      return {};
    } catch (e) {
      print('Error getting item details from TMDB: $e');
      return {};
    }
  }

  /// Récupère tous les détails TMDB pour une liste d'items communs
  static Future<List<Map<String, dynamic>>> getCommonItemsDetails(
    String userId1,
    String userId2,
  ) async {
    try {
      final commonIds = await getCommonItems(userId1, userId2);
      final List<Map<String, dynamic>> details = [];

      for (final itemId in commonIds) {
        final itemDetails = await getItemDetailsFromTMDB(itemId);
        if (itemDetails.isNotEmpty) {
          // Ajouter le type et l'ID original pour référence
          itemDetails['itemId'] = itemId;
          final kind = itemId.split('_')[0];
          itemDetails['itemKind'] = kind;
          details.add(itemDetails);
        }
      }

      return details;
    } catch (e) {
      print('Error getting common items details: $e');
      return [];
    }
  }
}
