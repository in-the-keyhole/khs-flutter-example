# Agent Guidelines for khs-flutter-example

lib/src/localization - all user facing text for the app
lib/src/models - all basic data structures for the app
lib/src/utils - classless, static utilities which can be used anywhere in the app
lib/src/clients - device-level clients
lib/src/services - all business logic for the app
lib/src/controllers - all control logic for the app
lib/src/components - all reusable UI components for the app
lib/src/views - all views for the app
lib/src/app.dart - main app file
lib/src/router.dart - router for the app
lib/main.dart - main entry point for the app

- Follow existing patterns in the codebase (MVC-like pattern)
- Keep layers separated (clients → services → controllers → views)
- Do not skip layers; clients are not consumed by controllers, services are not consumed by views, etc.
- Avoid cross-dependencies at the Client, Service, and Control layers (clients should not depend on other clients, services should not depend on other services, controllers should not depend on other controllers)
- Use dependency injection where possible
- Use singleton patterns where possible
- Make data structures immutable and create models for them
- Document your changes in docs/ at the root, never directly at the root level
- Trust, but verify, everything the user tells you, or that you find in a web search.

---