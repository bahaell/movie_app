import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/user_profile_service.dart';

class UserAvatarButton extends StatefulWidget {
  const UserAvatarButton({super.key});

  @override
  State<UserAvatarButton> createState() => _UserAvatarButtonState();
}

class _UserAvatarButtonState extends State<UserAvatarButton> {
  bool _uploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.data()?['photoUrl']?.toString() ?? '';
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: _uploading ? null : () => _pickAndUpload(uid),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white10,
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                if (_uploading)
                  const SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(String uid) async {
    if (_uploading) return;

    if (_supportsImagePicker) {
      final source = await _requestImageSource();
      if (source == null) return;
      await _pickViaImagePicker(uid, source);
    } else {
      await _pickViaFilePicker(uid);
    }
  }

  bool get _supportsImagePicker {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  bool get _cameraEnabled {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  Future<ImageSource?> _requestImageSource() async {
    if (!_cameraEnabled) return ImageSource.gallery;
    if (!mounted) return null;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickViaImagePicker(String uid, ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final extension = _extensionFromName(picked.name);
      await _uploadBytes(uid, bytes, extension);
    } catch (e) {
      _showError('Impossible de récupérer cette image: $e');
    }
  }

  Future<void> _pickViaFilePicker(String uid) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );
      if (result == null || result.files.isEmpty) return;

      final PlatformFile file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.readStream != null) {
        bytes = await _consumeStream(file.readStream!);
      }
      if (bytes == null) {
        _showError('Impossible de lire cette image.');
        return;
      }

      final extension = _extensionFromName(
        file.name.isNotEmpty ? file.name : (file.extension ?? 'jpg'),
      );
      await _uploadBytes(uid, bytes, extension);
    } catch (e) {
      _showError('Erreur lors de la sélection: $e');
    }
  }

  Future<void> _uploadBytes(String uid, Uint8List bytes, String extension) async {
    try {
      if (mounted) setState(() => _uploading = true);
      final url = await UserProfileService.uploadProfilePhoto(
        uid,
        bytes,
        contentType: _contentTypeForExtension(extension),
        fileExtension: extension,
      );
      if (url != null) {
        await UserProfileService.updatePhotoUrl(uid, url);
        _showSnack('Photo de profil mise à jour ✅');
      }
    } catch (e) {
      _showError('Erreur lors du téléversement: $e');
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<Uint8List> _consumeStream(Stream<List<int>> stream) async {
    final builder = BytesBuilder();
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  String _extensionFromName(String name) {
    final candidate = name.contains('.') ? name.split('.').last : name;
    final sanitized = candidate.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return sanitized.isEmpty ? 'jpg' : sanitized;
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    _showSnack(message);
  }
}
