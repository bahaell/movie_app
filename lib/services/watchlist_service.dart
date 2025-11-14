import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistService {
  static final _users = FirebaseFirestore.instance.collection('users');

  /// Add an item to the watchlist (movie_id or tv_id format)
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

  /// Remove an item from the watchlist
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

  /// Listen to watchlist changes in real-time
  static Stream<List<String>> watchlistStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return <String>[];
      return List<String>.from(data['favorites'] ?? []);
    });
  }

  /// Get watchlist once (no listener)
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

  /// Check if an item is in the watchlist
  static Future<bool> isInWatchlist(int id, String kind, String uid) async {
    final list = await getWatchlistOnce(uid);
    return list.contains('${kind}_$id');
  }
}
