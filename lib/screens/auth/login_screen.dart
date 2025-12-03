import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/screens/admin/admin_home.dart';
import '../user/user_main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading=false;

  Future<void> login() async {
    setState(()=>loading=true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
      final doc = await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).get();
      final data = doc.data() ?? {};
      if ((data['disabled'] ?? false) == true) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compte désactivé')));
        setState(()=>loading=false);
        return;
      }
      if (!mounted) return;
      final isAdmin = data['isAdmin'] ?? false;
      if (isAdmin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
      } else {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserMain()));
      }
    } catch (e) {
      if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(()=>loading=false);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Container(width:420, padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Connexion', style: TextStyle(color: Color(0xFF53FC18), fontSize:22, fontWeight: FontWeight.bold)),
        const SizedBox(height:12),
        TextField(controller: email, decoration: const InputDecoration(labelText:'Email')),
        const SizedBox(height:8),
        TextField(controller: pass, obscureText:true, decoration: const InputDecoration(labelText:'Password')),
        const SizedBox(height:12),
        ElevatedButton(onPressed: loading?null: login, child: loading? const CircularProgressIndicator(color: Colors.black): const Text('Login')),
        TextButton(onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Créer un compte', style: TextStyle(color: Color(0xFF53FC18))))
      ]))),
    );
  }
}
