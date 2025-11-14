import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// LOGIN
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners();
    return cred.user;
  }

  /// REGISTER
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int age,
    required File? photo,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String photoUrl = "";

    if (photo != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('users_photos')
          .child('${cred.user!.uid}.jpg');

      await ref.putFile(photo);
      photoUrl = await ref.getDownloadURL();
    }

    await _db.collection("users").doc(cred.user!.uid).set({
      "firstName": firstName,
      "lastName": lastName,
      "age": age,
      "photoUrl": photoUrl,
      "isAdmin": false,
      "disabled": false,
      "favorites": [],
    });

    notifyListeners();
    return cred.user;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.data();
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
