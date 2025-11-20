# Movie App

Une application Flutter pour découvrir, partager et matcher des films avec d'autres utilisateurs.

## Fonctionnalités

- **Authentification**: Inscription et connexion avec Firebase
- **Découverte de films**: Parcourez les films populaires via l'API TMDB
- **Playlist personnelle**: Ajoutez vos films préférés à une playlist
- **Système de matching**: Trouvez des utilisateurs avec les mêmes goûts cinématographiques
- **Panneau d'administration**: Gestion complète de l'application
- **Interface responsive**: Support mobile, web, desktop et tablette

## Structure du projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── app_theme.dart         # Thème de l'application (clair/sombre)
├── firebase_options.dart  # Configuration Firebase
├── models/
│   ├── user_model.dart    # Modèle utilisateur
│   └── movie_model.dart   # Modèle film
├── services/
│   ├── auth_service.dart       # Service d'authentification Firebase
│   ├── firestore_service.dart  # Service Firestore
│   └── tmdb_service.dart       # Service TMDB API
├── screens/
│   ├── login_screen.dart       # Écran de connexion
│   ├── register_screen.dart    # Écran d'inscription
│   ├── home_screen.dart        # Écran principal
│   ├── playlist_screen.dart    # Écran de la playlist
│   ├── admin_screen.dart       # Panneau d'administration
│   └── match_screen.dart       # Écran de matching
└── widgets/
    └── movie_tile.dart    # Widget tuile de film
```

## Dépendances principales

- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **API TMDB**: `http` package
- **UI**: Material 3 avec `flutter_adaptive_scaffold`

## Configuration

### 1. Firebase Setup

Créez un projet Firebase et configurez les credentials dans `firebase_options.dart`:
- Web App ID
- Android App ID
- iOS App ID

### 2. TMDB API

Obtenez une clé API gratuite sur [The Movie Database (TMDB)](https://www.themoviedb.org/settings/api) et configurez-la dans `lib/services/tmdb_service.dart`.

### 3. Dépendances

```bash
flutter pub get
```

## Exécution

### Mode développement
```bash
flutter run
```

### Build production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## CI/CD

Un workflow GitHub Actions est configuré pour:
- Exécuter l'analyse Dart
- Lancer les tests
- Builder les applications
- Uploader les artifacts

Fichier: `.github/workflows/flutter_ci.yml`

## Modèles de données

### UserModel
- `uid`: Identifiant unique Firebase
- `email`: Adresse email
- `username`: Nom d'utilisateur
- `profileImageUrl`: URL de l'avatar
- `isAdmin`: Statut administrateur
- `createdAt`: Date de création

### MovieModel
- `id`: Identifiant TMDB
- `title`: Titre du film
- `description`: Description/synopsis
- `posterPath`: URL de l'affiche
- `backdropPath`: URL du backdrop
- `voteAverage`: Note moyenne
- `releaseDate`: Date de sortie
- `genres`: Liste des genres
- `isInPlaylist`: Ajouté à la playlist
- `addedToPlaylistAt`: Date d'ajout à la playlist

## Services

### AuthService
Gestion complète de l'authentification:
- `signUp()`: Inscription
- `signIn()`: Connexion
- `signOut()`: Déconnexion
- `resetPassword()`: Réinitialisation

### FirestoreService
Gestion de Firestore:
- Gestion des utilisateurs
- Gestion des playlists
- Gestion des matchs

### TMDBService
Requêtes API TMDB:
- Récupération des films populaires
- Recherche de films
- Détails des films

## Écrans

### Login Screen
Écran de connexion avec validation

### Register Screen
Inscription avec confirmation de mot de passe

### Home Screen
- Liste des films populaires
- Barre de recherche
- Grille des films avec détails

### Playlist Screen
- Visualisation de la playlist personnelle
- Suppression de films
- Stream en temps réel Firestore

### Admin Screen
- Gestion des utilisateurs
- Gestion des films
- Rapports et statistiques
- Paramètres

### Match Screen
- Liste des matchs avec d'autres utilisateurs
- Films en commun
- Détails des matchs

## Widgets

### MovieTile
Widget réutilisable pour afficher un film:
- Image de couverture
- Titre
- Note
- Bouton pour ajouter/retirer de la playlist

## Thème

L'application utilise Material Design 3 avec:
- Couleur primaire: Deep Purple
- Support mode clair/sombre
- Design responsive

## Notes de développement

- Les chemins API TMDB sont relatifs à `https://api.themoviedb.org/3`
- Les images TMDB sont hébergées sur `https://image.tmdb.org/t/p/w500`
- La collection Firestore utilise des documents imbriqués pour les playlists
- Les timestamps utilisent le format ISO 8601

## Licence

MIT

## Auteur

Créé avec ❤️ pour les amateurs de films
