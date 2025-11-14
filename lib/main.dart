import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_user_page.dart';
import 'screens/favorites_page.dart';
import 'screens/admin_dashboard.dart';
// user pages (additional)
import 'pages/user/search_page.dart';
import 'pages/user/movie_details.dart';
import 'pages/user/tv_details.dart';
import 'pages/user/home_user_connected.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (do NOT commit the real .env)
  await dotenv.load(fileName: '.env');

  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAipS9VCfnpN2PW_INtF6uRkNy5Iy_WKiY",
    authDomain: "movieapp-64389.firebaseapp.com",
    projectId: "movieapp-64389",
    storageBucket: "movieapp-64389.firebasestorage.app",
    messagingSenderId: "788156325298",
    appId: "1:788156325298:web:55d57ef97fed61bf7a98ab",
  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      theme: AppTheme.lightTheme,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
  // Use the connected user home as the main user screen (merged skeleton + live data)
  '/user': (context) => const UserHomePage(),
        '/user_connected': (context) => const UserHomePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/admin': (context) => const AdminDashboard(),
        '/search': (context) => const SearchPage(),
        '/movie': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return MovieDetailsPage(movieId: id);
        },
        '/tv': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return TvDetailsPage(tvId: id);
        },
      },
    );
  }
}
