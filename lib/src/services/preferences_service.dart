import 'package:flutter/material.dart';

import '../clients/local_preferences_client.dart';

/// A service that stores and retrieves app preferences.
///
/// This service uses the LocalPreferencesClient to persist preferences
/// to the device's local storage.
class PreferencesService {
  PreferencesService(this._localPreferencesClient);

  final LocalPreferencesClient _localPreferencesClient;

  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  late ThemeMode _themeMode;
  Locale? _locale;
  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current theme mode setting.
  ThemeMode get themeMode => _themeMode;

  /// The current locale setting. Null means use system locale.
  Locale? get locale => _locale;

  /// Initialize the service by loading preferences from storage.
  Future<void> init() async {
    _themeMode = await _loadThemeMode();
    _locale = await _loadLocale();
    _isInitialized = true;
  }

  /// Loads the User's preferred ThemeMode from local storage.
  Future<ThemeMode> _loadThemeMode() async {
    final themeModeString = await _localPreferencesClient.getString(
      _themeModeKey,
    );

    if (themeModeString == null) {
      return ThemeMode.system;
    }

    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Loads the User's preferred Locale from local storage.
  Future<Locale?> _loadLocale() async {
    final localeString = await _localPreferencesClient.getString(_localeKey);
    if (localeString == null) {
      return null;
    }
    return Locale(localeString);
  }

  /// Persists the user's preferred ThemeMode to local storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    _themeMode = theme;
    await _localPreferencesClient.setString(_themeModeKey, theme.name);
  }

  /// Persists the user's preferred Locale to local storage.
  /// Pass null to use system locale.
  Future<void> updateLocale(Locale? locale) async {
    _locale = locale;
    if (locale == null) {
      await _localPreferencesClient.remove(_localeKey);
    } else {
      await _localPreferencesClient.setString(_localeKey, locale.languageCode);
    }
  }
}
