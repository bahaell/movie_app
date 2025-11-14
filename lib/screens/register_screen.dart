import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'user_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  File? photo;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text("Create Account",
                    style: TextStyle(
                        fontSize: 28,
                        color: Color(0xFF53FC18),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      setState(() => photo = File(img.path));
                    }
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: photo != null ? FileImage(photo!) : null,
                    child: photo == null
                        ? const Icon(Icons.camera_alt,
                            color: Color(0xFF53FC18))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(controller: firstCtrl, decoration: const InputDecoration(hintText: "First Name")),
                TextField(controller: lastCtrl, decoration: const InputDecoration(hintText: "Last Name")),
                TextField(controller: ageCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Age")),
                TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: "Email")),
                TextField(controller: passCtrl, obscureText: true,
                    decoration: const InputDecoration(hintText: "Password")),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53FC18),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);

                          try {
                            final auth = Provider.of<AuthService>(context, listen: false);
                            final user = await auth.register(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                              firstName: firstCtrl.text.trim(),
                              lastName: lastCtrl.text.trim(),
                              age: int.parse(ageCtrl.text.trim()),
                              photo: photo,
                            );

                            if (user != null && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")));
                          }

                          setState(() => loading = false);
                        },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
