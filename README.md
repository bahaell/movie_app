# movie_app
## Environment variables

This project uses a `.env` file to store API keys and secrets locally.

- Copy `.env.example` to `.env` at the project root:

```
cp .env.example .env
```

- Edit `.env` and fill your real TMDB API key (and Firebase keys if you choose). The `.env` file is already ignored by `.gitignore` to avoid leaking secrets.

The app loads environment variables at startup (via `flutter_dotenv`), and services read `TMDB_API_KEY` from the environment. If the environment variable is missing, a built-in fallback key will be used.


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
