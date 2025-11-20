import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users collection
  CollectionReference get usersRef => _db.collection('users');
  CollectionReference get moviesRef => _db.collection('movies');

  Future<void> createUserDocument(String uid, AppUser user) {
    return usersRef.doc(uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await usersRef.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data() as Map<String, dynamic>, uid);
  }

  Future<void> updateFavorites(String uid, List<String> favorites) {
    return usersRef.doc(uid).update({'favorites': favorites});
  }

  Future<void> setDisabled(String uid, bool disabled) {
    return usersRef.doc(uid).update({'disabled': disabled});
  }

  Future<void> addMovie(MovieModel movie) {
    return moviesRef.doc(movie.id).set(movie.toMap());
  }

  Stream<List<MovieModel>> streamMovies() {
    return moviesRef.snapshots().map((snap) => snap.docs
        .map((d) => MovieModel.fromMap(d.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<AppUser>> streamAllUsers() {
    return usersRef.snapshots().map((snap) => snap.docs
        .map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }
}
