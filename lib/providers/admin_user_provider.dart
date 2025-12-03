import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final bool isAdmin;
  final bool disabled;
  AdminUser({required this.uid, required this.firstName, required this.lastName, this.photoUrl, this.isAdmin=false, this.disabled=false});
}

class AdminUserProvider with ChangeNotifier {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  bool loading = false;
  List<AdminUser> users = [];

  AdminUserProvider() {
    loadUsers();
  }

  Future<void> loadUsers() async {
    loading = true; notifyListeners();
    final snap = await usersRef.get();
    users = snap.docs.map((d) {
      final data = d.data() as Map<String,dynamic>;
      return AdminUser(
        uid: d.id,
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        photoUrl: data['photoUrl'],
        isAdmin: data['isAdmin'] ?? false,
        disabled: data['disabled'] ?? false,
      );
    }).toList();
    loading = false; notifyListeners();
  }

  Future<void> toggleDisable(String uid, bool current) async {
    await usersRef.doc(uid).update({'disabled': !current});
    await loadUsers();
  }

  Future<void> setAdmin(String uid, bool value) async {
    await usersRef.doc(uid).update({'isAdmin': value});
    await loadUsers();
  }
}