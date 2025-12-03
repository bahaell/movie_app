import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  Future<bool> isAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String,dynamic>;
    return data['isAdmin'] ?? false;
  }

  Future<bool> isDisabled(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return true;
    final data = doc.data() as Map<String,dynamic>;
    return data['disabled'] ?? false;
  }
}
