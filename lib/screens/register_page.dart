import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Uint8List? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _image = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String> _uploadImage(String uid) async {
    final ref = FirebaseStorage.instance.ref("users_photos/$uid.jpg");
    await ref.putData(_image!, SettableMetadata(contentType: "image/jpeg"));
    return await ref.getDownloadURL();
  }

  Future<void> _register() async {
    if (_first.text.isEmpty ||
        _last.text.isEmpty ||
        _age.text.isEmpty ||
        _email.text.isEmpty ||
        _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      String photoUrl = "";
      if (_image != null) {
        photoUrl = await _uploadImage(cred.user!.uid);
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user!.uid)
          .set({
        "firstName": _first.text.trim(),
        "lastName": _last.text.trim(),
        "age": int.parse(_age.text.trim()),
        "photoUrl": photoUrl,
        "isAdmin": false,
        "disabled": false,
        "favorites": []
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _age.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        _image != null ? MemoryImage(_image!) : null,
                    backgroundColor: Colors.grey.shade800,
                    child: _image == null
                        ? const Icon(Icons.camera_alt, color: Color(0xFF53fc18))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_first, "First Name"),
                _buildTextField(_last, "Last Name"),
                _buildTextField(_age, "Age",
                    keyboardType: TextInputType.number),
                _buildTextField(_email, "Email"),
                _buildTextField(_pass, "Password", obscure: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53fc18),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Register"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF53fc18)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF53fc18))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF53fc18), width: 2)),
        ),
      ),
    );
  }
}
