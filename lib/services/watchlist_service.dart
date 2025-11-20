import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistService {
  static final _users = FirebaseFirestore.instance.collection('users');

  /// Add: store simple tag like 'movie_1234' or 'tv_9981'
  static Future<void> addToWatchlist(int id, String kind) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final tag = '${kind}_$id';

      await _users.doc(uid).update({
        'favorites': FieldValue.arrayUnion([tag])
      });
    } catch (e) {
      print('Error adding to watchlist: $e');
      rethrow;
    }
  }

  // Convenience wrappers for clarity when reading call sites
  static Future<void> addMovie(int id) => addToWatchlist(id, 'movie');
  static Future<void> addTv(int id) => addToWatchlist(id, 'tv');
  static Future<void> removeMovie(int id) => removeFromWatchlist(id, 'movie');
  static Future<void> removeTv(int id) => removeFromWatchlist(id, 'tv');

  /// Remove
  static Future<void> removeFromWatchlist(int id, String kind) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final tag = '${kind}_$id';

      await _users.doc(uid).update({
        'favorites': FieldValue.arrayRemove([tag])
      });
    } catch (e) {
      print('Error removing from watchlist: $e');
      rethrow;
    }
  }

  /// Listen realtime — returns List<String>
  static Stream<List<String>> watchlistStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return <String>[];
      return List<String>.from(data['favorites'] ?? []);
    });
  }

  /// Fetch once — returns List<String>
  static Future<List<String>> getWatchlistOnce(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      final data = snap.data();
      if (data == null) return [];
      return List<String>.from(data['favorites'] ?? []);
    } catch (e) {
      print('Error fetching watchlist: $e');
      return [];
    }
  }

  /// Check if exists
  static Future<bool> isInWatchlist(int id, String kind, String uid) async {
    final list = await getWatchlistOnce(uid);
    return list.contains('${kind}_$id');
  }

  static Future<bool> isMovie(int id, String uid) => isInWatchlist(id, 'movie', uid);
  static Future<bool> isTv(int id, String uid) => isInWatchlist(id, 'tv', uid);
}
