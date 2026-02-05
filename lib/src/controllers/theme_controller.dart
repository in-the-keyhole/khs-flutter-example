import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The ThemeController
/// uses the PreferencesService to store and retrieve user settings.
class ThemeController with ChangeNotifier {
  ThemeController(this._preferencesService);

  final PreferencesService _preferencesService;

  /// The current theme mode setting.
  ThemeMode get mode => _preferencesService.themeMode;

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _preferencesService.themeMode) return;

    await _preferencesService.updateThemeMode(newThemeMode);
    notifyListeners();
  }
}
