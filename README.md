# khs-flutter-example

A Flutter example project demonstrating clean architecture patterns, persistent storage, user management, and atomic design components.

## Architecture

This project follows a **clean architecture pattern** with clear separation of concerns:

- **Clients** - Low-level data access (preferences, database, filesystem, gallery)
- **Services** - Business logic consuming clients
- **Controllers** - State management consuming services
- **Models** - Immutable data structures
- **Views** - Top-level UI pages
- **Components** - Reusable UI components (atoms, molecules, organisms)
- **Router** - Centralized navigation

See `AGENTS.md` for detailed architecture guidelines.

## Features

- **User Management** - Multi-user support with roles (Admin/User)
- **Persistent Storage** - SQLite database + SharedPreferences
- **User-Specific Settings** - Isolated preferences per user
- **Theme Support** - Light/Dark/System theme modes
- **Localization** - English and Spanish support
- **Atomic Design** - Component library (atoms → molecules → organisms)

## Getting Started

### Prerequisites

- Flutter SDK (see `pubspec.yaml` for version)
- iOS: Xcode (for macOS/iOS builds)
- Android: Android SDK

### Installation

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test
```

## Project Structure

```
lib/
├── main.dart              # App entry point
└── src/
    ├── app.dart           # App configuration
    ├── router.dart        # Navigation
    ├── clients/           # Data access layer
    ├── services/          # Business logic
    ├── controllers/       # State management
    ├── models/            # Data structures
    ├── views/             # Top-level pages
    ├── components/        # Reusable UI components
    └── localization/      # i18n files
```

## Development

See `AGENTS.md` for coding guidelines and architecture patterns.

### Key Commands

- `flutter run` - Run the app
- `flutter test` - Run tests
- `flutter analyze` - Lint code
- `flutter build [platform]` - Build for platform

### Database

SQLite database initialized in `main.dart` with users table. Default "Admin" user created on first launch.

### Localization

ARB files in `lib/src/localization/`. Run `flutter pub get` after modifying ARB files to regenerate localization code.
