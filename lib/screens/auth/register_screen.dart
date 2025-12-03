import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  final age = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final photoUrlCtrl = TextEditingController();
  // Image upload disabled (image_picker removed)
  bool loading=false;

  /*
  Future<void> pickImage() async {
    final p = ImagePicker();
    final img = await p.pickImage(source: ImageSource.gallery);
    if (img!=null) { setState(()=> photo = File(img.path)); }
  }
  */

  Future<void> register() async {
    setState(()=>loading=true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
  final photoUrl = photoUrlCtrl.text.trim();
      /*
      if (photo!=null) {
        final ref = FirebaseStorage.instance.ref().child('users_photos/${cred.user!.uid}.jpg');
        await ref.putFile(photo!);
        photoUrl = await ref.getDownloadURL();
      }
      */
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'firstName': first.text.trim(),
        'lastName': last.text.trim(),
        'age': int.tryParse(age.text.trim()) ?? 0,
        'photoUrl': photoUrl,
        'isAdmin': false,
        'disabled': false,
        'favorites': []
      });
      // Auto login: user already authenticated; navigate to root
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    if (mounted) {
      setState(()=>loading=false);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 420, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey,
              backgroundImage: photoUrlCtrl.text.trim().isNotEmpty ? NetworkImage(photoUrlCtrl.text.trim()) : null,
            ),
            const SizedBox(height:12),
            TextField(controller: first, decoration: const InputDecoration(labelText:'First Name')),
            const SizedBox(height:8),
            TextField(controller: last, decoration: const InputDecoration(labelText:'Last Name')),
            const SizedBox(height:8),
            TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText:'Age')),
            const SizedBox(height:8),
            TextField(controller: email, decoration: const InputDecoration(labelText:'Email')),
            const SizedBox(height:8),
            TextField(controller: pass, obscureText:true, decoration: const InputDecoration(labelText:'Password')),
            const SizedBox(height:8),
            TextField(
              controller: photoUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optionnel)',
                hintText: 'https://.../photo.jpg',
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) { if (mounted) setState(() {}); },
            ),
            const SizedBox(height:16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF53FC18), foregroundColor: Colors.black),
              onPressed: loading?null: register,
              child: loading? const CircularProgressIndicator(color: Colors.black): const Text('Register')
            )
          ]),
        ),
      )),
    );
  }
}
