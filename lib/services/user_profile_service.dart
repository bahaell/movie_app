import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileService {
  static final _usersRef = FirebaseFirestore.instance.collection('users');
  static final _storage = FirebaseStorage.instance;

  static Future<String?> uploadProfilePhoto(
    String uid,
    Uint8List data, {
    String contentType = 'image/jpeg',
    String fileExtension = 'jpg',
  }) async {
    try {
      final sanitizedExtension = fileExtension.trim().isEmpty ? 'jpg' : fileExtension;
      final ref = _storage.ref().child('user_photos/$uid/profile.$sanitizedExtension');
      await ref.putData(data, SettableMetadata(contentType: contentType));
      return ref.getDownloadURL();
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> updatePhotoUrl(String uid, String url) async {
    await _usersRef.doc(uid).set({
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<String> photoUrlStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      return data?['photoUrl']?.toString() ?? '';
    });
  }
}
