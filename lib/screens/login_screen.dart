import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'user_home_screen.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Login",
                  style: TextStyle(
                      fontSize: 28, color: Color(0xFF53FC18), fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),
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
                          final user = await auth.login(emailCtrl.text.trim(), passCtrl.text.trim());

                          if (user == null) return;

                          final data = await auth.getUserData(user.uid);
                          final isAdmin = data?["isAdmin"] ?? false;

                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => isAdmin
                                    ? const AdminHomeScreen()
                                    : const UserHomeScreen(),
                              ),
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
                    : const Text("Login"),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/register"),
                child: const Text("Create account",
                    style: TextStyle(color: Color(0xFF53FC18))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
