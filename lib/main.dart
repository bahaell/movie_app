import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/admin_movie_provider.dart';
import 'providers/admin_user_provider.dart';
import 'providers/search_provider.dart';
import 'providers/movie_details_provider.dart';
import 'providers/discovery_provider.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'screens/admin/admin_home.dart';
import 'screens/admin/admin_main.dart';
import 'screens/user/user_main.dart';
import 'screens/user/search_screen.dart';
import 'screens/user/favorites_screen.dart';
import 'screens/user/movie_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => MovieProvider()),
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    ChangeNotifierProvider(create: (_) => MovieDetailsProvider()),
    ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
    ChangeNotifierProvider(create: (_) => AdminProvider()),
    ChangeNotifierProvider(create: (_) => AdminMovieProvider()),
    ChangeNotifierProvider(create: (_) => AdminUserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/admin': (_) => const AdminHomePage(),
          '/search': (_) => const SearchScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/details': (_) => const MovieDetailsScreen(),
        },
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  Future<bool> _checkUserRole(BuildContext context, String uid) {
    return Provider.of<AuthProvider>(context, listen: false).isAdmin(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (!snap.hasData) return const LoginScreen();
        final user = snap.data!;
        return FutureBuilder<bool>(
          future: _checkUserRole(context, user.uid),
          builder: (context, asnap) {
            if (!asnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return asnap.data == true ? const AdminMain() : const UserMain();
          },
        );
      },
    );
  }
}

