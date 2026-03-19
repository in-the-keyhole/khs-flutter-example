# Agent Guidelines for khs-flutter-example

Guidelines for AI coding agents working on this Flutter project.

## Project Architecture

Clean architecture with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point, initialization
├── src/
    ├── app.dart              # App configuration (themes, localization)
    ├── router.dart           # Centralized routing logic
    ├── clients/              # Low-level data access (API, storage, device)
    ├── services/             # Business logic, consumes clients
    ├── controllers/          # State management, consumes services
    ├── models/               # Data structures, shared across layers
    ├── views/                # Top level UI views
    ├── components/           # Reusable UI components
    └── localization/         # Generated i18n files
```

## Core Principles

1. Follow existing patterns (MVC-like)
2. Keep layers separated (clients → services → controllers → views)
3. Do not skip layers
4. Avoid cross-dependencies within same layer
5. Use dependency injection
6. Make data structures immutable
7. Document changes
8. Trust, but verify

---