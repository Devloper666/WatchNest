# WatchNest

WatchNest is a Flutter media tracker that helps you organize movies, TV shows, favorites, and watch progress in one place. The app follows a clean architecture with Provider-based state management and a repository-style data layer for TMDB-backed content.

## Features

- Browse popular movies, TV shows, and trending titles
- Search the TMDB catalog
- Save titles to a watchlist
- Mark items as watching, completed, planned, or dropped
- Keep favorites synced and persisted across restarts
- View real library statistics from your saved data

## Screenshots

Add screenshots to the screenshots/ folder and reference them here when available.

## Tech Stack

- Flutter
- Provider
- Dio
- SharedPreferences
- Firebase Auth
- TMDB API

## Folder Structure

```
lib/
├── app/
│   ├── watchnest_app.dart
│   └── watchnest_shell.dart
├── core/
│   ├── constants/
│   ├── network/
│   ├── persistence/
│   └── theme/
├── features/
│   ├── auth/
│   ├── details/
│   ├── home/
│   ├── media/
│   ├── profile/
│   ├── search/
│   ├── stats/
│   └── watchlist/
├── models/
├── screens/
├── services/
├── shared/
│   └── widgets/
└── main.dart
```

## Architecture Overview

The app is organized into feature-based layers:

- presentation: screens and widgets
- domain: entities and use cases
- data: repositories and remote data sources
- core: networking, persistence, and shared constants

## Installation

1. Install Flutter 3.12 or newer.
2. Clone the repository.
3. Run:

   flutter pub get

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Add Android and iOS apps to your Firebase project.
3. Download the configuration files:
   - `google-services.json` for Android → place in `android/app/`
   - `GoogleService-Info.plist` for iOS → place in `ios/Runner/`
4. Enable Authentication providers (Email/Password and Google Sign-In) in the Firebase console.

## TMDB Setup

The app reads the TMDB bearer token from a build-time define:

- `--dart-define=TMDB_TOKEN=your_token`
- `--dart-define-from-file=.env.json`

Create a `.env.json` file in the project root with this structure:

```json
{
  "TMDB_TOKEN": "YOUR_TMDB_BEARER_TOKEN"
}
```

The file is ignored by Git so your real token never gets committed.

## Running the App

From the project root, run:

```bash
flutter run
```

VS Code launch configuration is already set up to pass `--dart-define-from-file=.env.json` automatically when you press F5 or use Run.

## Building APKs

To build an APK, run:

```bash
flutter build apk
```

The build uses the same `.env.json` file automatically when the app is launched or built from VS Code.

## Roadmap

- Improve onboarding and empty states
- Add richer media filters and sorting
- Expand stats with weekly and monthly insights

## License

This project is licensed under the MIT License.
