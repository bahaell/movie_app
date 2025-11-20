import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_user_page.dart';
import 'screens/favorites_page.dart';
import 'screens/admin/admin_home_page.dart';
import 'pages/user/search_page.dart';
import 'pages/user/movie_details.dart';
import 'pages/user/home_user_connected.dart';
import 'pages/user/matching_page.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (do NOT commit the real .env)
  // On web, the .env file must be in the web/ folder to be accessible
  try {
    if (kIsWeb) {
      // For web, try loading from the web root
      await dotenv.load(fileName: '.env');
    } else {
      // For mobile, load from project root
      await dotenv.load(fileName: '.env');
    }
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    // Continue anyway — fallback values will be used
  }

  // If running on the web we must provide FirebaseOptions. For mobile
  // (Android/iOS) the native configuration files (google-services.json /
  // GoogleService-Info.plist) are used and no options are required here.
  final hasFirebaseWebConfig = kIsWeb &&
      dotenv.env['FIREBASE_API_KEY'] != null &&
      dotenv.env['FIREBASE_AUTH_DOMAIN'] != null &&
      dotenv.env['FIREBASE_PROJECT_ID'] != null &&
      dotenv.env['FIREBASE_STORAGE_BUCKET'] != null &&
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] != null &&
      dotenv.env['FIREBASE_APP_ID'] != null &&
      dotenv.env['FIREBASE_MEASUREMENT_ID'] != null;

  if (kIsWeb && hasFirebaseWebConfig) {
    final firebaseOptionsForWeb = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    );
    await Firebase.initializeApp(options: firebaseOptionsForWeb);
  } else if (kIsWeb && !hasFirebaseWebConfig) {
    // Skip Firebase init on web if config missing to allow UI to load.
    debugPrint(
        'Firebase web configuration missing; skipping initialization. Provide keys in .env to enable auth/storage.');
  } else {
    await Firebase.initializeApp();
  }

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
        '/user': (context) => const HomeUserPage(),
        '/user_connected': (context) => const UserHomePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/matching': (context) => const MatchingPage(),
        '/admin': (context) => const AdminHomePage(),
        '/search': (context) => const SearchPage(),
        '/movie': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as int;
          return MovieDetailsPage(movieId: id);
        },
      },
    );
  }
}
