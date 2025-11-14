# movie_app
## Environment variables

This project uses a `.env` file to store API keys and secrets locally.

- Copy `.env.example` to `.env` at the project root:

```
cp .env.example .env
```

- Edit `.env` and fill your real TMDB API key and (optionally) Firebase web keys. For Flutter web you must provide the Firebase web config values (see below). The `.env` file is already ignored by `.gitignore` to avoid leaking secrets.

The app loads environment variables at startup (via `flutter_dotenv`), and services read `TMDB_API_KEY` from the environment. If the environment variable is missing, a built-in fallback key will be used.

Firebase web configuration

- To run the app on Flutter web, add your Firebase web config to `.env` (these values come from Firebase Console → Project Settings → Your apps (Web)):

```
FIREBASE_API_KEY=AIzaSyYourApiKeyHere
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=1234567890
FIREBASE_APP_ID=1:1234567890:web:abcdef123456
FIREBASE_MEASUREMENT_ID=G-ABCDEFG123
```

- Important: DO NOT commit your `.env` file. Keep it local and secure.


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# movie_app
