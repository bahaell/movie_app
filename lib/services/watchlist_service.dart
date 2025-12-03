import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistService {
  static CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  static Future<void> addToWatchlist(String movieId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    await usersRef.doc(uid).update({
      'favorites': FieldValue.arrayUnion([movieId])
    });
  }

  static Future<void> removeFromWatchlist(String movieId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    await usersRef.doc(uid).update({
      'favorites': FieldValue.arrayRemove([movieId])
    });
  }

  static Stream<List<String>> watchlistStream(String uid) {
    return usersRef.doc(uid).snapshots().map((snap) {
      final data = snap.data() as Map<String,dynamic>?;
      if (data == null) return <String>[];
      return List<String>.from(data['favorites'] ?? []);
    });
  }

  static Future<List<String>> getWatchlistOnce(String uid) async {
    final snap = await usersRef.doc(uid).get();
    final data = snap.data() as Map<String,dynamic>?;
    if (data == null) return [];
    return List<String>.from(data['favorites'] ?? []);
  }

  static Future<void> purgeMovieFromAllUsers(String movieId) async {
    final query = await usersRef.where('favorites', arrayContains: movieId).get();
    if (query.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'favorites': FieldValue.arrayRemove([movieId]),
      });
    }
    await batch.commit();
  }
}

