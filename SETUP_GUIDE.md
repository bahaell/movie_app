# 🎬 MovieApp - Guide de Configuration

## ✅ Prérequis

- Flutter 3.13+
- Dart 3.0+
- Firebase CLI
- TMDB API Key (gratuit)

---

## 🔧 Installation

### 1. Mettre à jour pubspec.yaml

```bash
cd movie_app
flutter pub get
```

### 2. Dépendances requises

Ajouter à `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.13.0
  provider: ^6.0.0
  http: ^1.1.0
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Puis:
```bash
flutter pub get
```

---

## 🔑 Configuration Firebase

### Déjà configuré pour Web:

```dart
// lib/main.dart
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAipS9VCfnpN2PW_INtF6uRkNy5Iy_WKiY",
  authDomain: "movieapp-64389.firebaseapp.com",
  projectId: "movieapp-64389",
  storageBucket: "movieapp-64389.firebasestorage.app",
  messagingSenderId: "788156325298",
  appId: "1:788156325298:web:55d57ef97fed61bf7a98ab",
);
```

### Pour Android/iOS (optionnel):

```bash
flutterfire configure
```

Suivre les instructions et sélectionner le projet "movieapp-64389"

---

## 🎥 Configuration TMDB API

### 1. Obtenir une clé API gratuite

1. Aller sur https://www.themoviedb.org/settings/api
2. Créer un compte (gratuit)
3. Demander une clé API
4. Copier la clé API (v3)

### 2. Ajouter la clé au projet

**Option A - Environnement local (développement):**

Créer `.env` à la racine du projet:
```
TMDB_API_KEY=votre_clé_ici
```

Puis utiliser `flutter_dotenv`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  final apiKey = dotenv.env['TMDB_API_KEY']!;
  // ...
}
```

**Option B - Variable d'environnement (production):**
```bash
export TMDB_API_KEY="votre_clé_ici"
```

Puis dans le code:
```dart
final apiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: 'YOUR_TMDB_API_KEY');
```

### 3. Mettre à jour home_screen.dart

```dart
late TmdbService _tmdbService;

@override
void initState() {
  super.initState();
  final apiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: 'YOUR_TMDB_API_KEY');
  _tmdbService = TmdbService(apiKey);
  _popularMovies = _tmdbService.searchPopular();
}
```

---

## 🗄️ Configuration Firestore

### Structure de collection:

```
users/
├─ {uid}
│  ├─ firstName: string
│  ├─ lastName: string
│  ├─ age: number
│  ├─ photoUrl: string
│  ├─ disabled: boolean
│  └─ favorites: array<string>

movies/
├─ {movieId}
│  ├─ id: string
│  ├─ title: string
│  ├─ posterPath: string
│  └─ overview: string
```

### Règles de sécurité Firestore:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users - Lecture/Écriture personnelle
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Movies - Lecture seule
    match /movies/{docId=**} {
      allow read: if request.auth != null;
    }
  }
}
```

### Configuration dans Firebase Console:

1. Aller sur https://console.firebase.google.com
2. Sélectionner "movieapp-64389"
3. Firestore Database → Créer database
4. Mode test (pour dev) → Créer
5. Ajouter les collections `users` et `movies`

---

## 🎨 Personnalisation du thème

### Couleurs actuelles:

```dart
class AppTheme {
  static const Color primaryGreen = Color(0xFF53FC18);  // Vert néon
  static const Color primaryBlack = Colors.black;        // Noir
}
```

### Pour modifier:

```dart
// lib/app_theme.dart
static const Color primaryGreen = Color(0xFF00FF00);  // Nouvelle couleur
```

Les 10 nuances seront générées automatiquement.

---

## 🚀 Lancer l'application

### Development (Web):
```bash
flutter run -d chrome
```

### Development (Émulateur Android):
```bash
flutter run
```

### Development (Simulateur iOS):
```bash
flutter run -d ios
```

### Production Build (Web):
```bash
flutter build web --release
```

### Déployer sur Firebase Hosting (Web):
```bash
firebase init hosting
flutter build web --release
firebase deploy
```

---

## 🧪 Tests

### Exécuter les tests:
```bash
flutter test
```

### Test unitaire - matching_util:
```dart
import 'package:movie_app/utils/matching_util.dart';

void main() {
  test('Jaccard similarity 50%', () {
    final similarity = jaccardSimilarity(['1', '2'], ['2', '3']);
    expect(similarity, 0.5);
  });
}
```

---

## 📱 Flow utilisateur

```
┌─────────────┐
│ App Launch  │
└──────┬──────┘
       │
       ├─ Authentifié? ──NO──→ LoginScreen → RegisterScreen
       │                              ↓
       │                        Home Screen (Root)
       │
       └─ Authentifié? ──YES─→ HomeScreen
                               ├─ Découvrir films (TMDB)
                               ├─ ❤️ Ajouter favoris
                               ├─ 👥 Voir matchs
                               └─ Logout
```

---

## 🐛 Débogage

### Voir les logs Firebase:
```bash
firebase emulators:start
```

### Profiler l'app:
```bash
flutter run --profile
```

### Analyser le code:
```bash
flutter analyze
```

---

## ⚠️ Problèmes courants

### 1. Firebase: "Project ID not found"
→ Vérifier que les credentials dans main.dart sont correctes
→ Vérifier la connexion internet

### 2. TMDB: "401 Unauthorized"
→ Vérifier la clé API
→ Vérifier qu'elle n'est pas révoquée sur TMDB

### 3. Firestore: "Missing/Invalid Authentication"
→ Vérifier les règles de sécurité
→ Vérifier que l'utilisateur est connecté

### 4. Images ne s'affichent pas
→ Vérifier que posterPath est un chemin relatif `/path/to/poster`
→ Vérifier que `tmdbService.imageUrl()` ajoute bien la base URL

---

## 📚 Documentation

- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [TMDB API Docs](https://developer.themoviedb.org/docs/getting-started)
- [Firestore Docs](https://cloud.google.com/firestore/docs)

---

## 🎯 Checklist avant production

- [ ] TMDB API key configurée
- [ ] Règles Firestore activées
- [ ] Firebase Web config vérifiée
- [ ] Tests unitaires passants
- [ ] Performance profiling OK
- [ ] Build web sans erreurs
- [ ] Images TMDB s'affichent
- [ ] Authentification fonctionne
- [ ] Matching >= 75% fonctionne
- [ ] Favoris synchronisés en temps réel

---

**Version:** 2.0
**Dernière mise à jour:** Novembre 2025
