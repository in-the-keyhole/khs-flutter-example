import 'package:flutter/material.dart';

import '../clients/local_preferences_client.dart';

/// A service that stores and retrieves app preferences.
///
/// This service uses the LocalPreferencesClient to persist preferences
/// to the device's local storage.
class UserPreferencesService {
  UserPreferencesService(this._localPreferencesClient);

  final LocalPreferencesClient _localPreferencesClient;

  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _selectedModelPathKey = 'selected_model_path';
  static const String _selectedModelNameKey = 'selected_model_name';
  static const String _contextSizeKey = 'context_size';
  static const String _systemPromptKey = 'system_prompt';

  static const int defaultContextSize = 4096;
  static const String defaultSystemPrompt = 'You are a helpful assistant.';

  late ThemeMode _themeMode;
  Locale? _locale;
  String? _selectedModelPath;
  String? _selectedModelName;
  int? _contextSize;
  String? _systemPrompt;
  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current theme mode setting.
  ThemeMode get themeMode => _themeMode;

  /// The current locale setting. Null means use system locale.
  Locale? get locale => _locale;

  /// The path of the previously selected model, if any.
  String? get selectedModelPath => _selectedModelPath;

  /// The display name of the previously selected model, if any.
  String? get selectedModelName => _selectedModelName;

  /// The context size for model loading. Defaults to 4096.
  int get contextSize => _contextSize ?? defaultContextSize;

  /// The system prompt for chat. Defaults to a generic helpful assistant prompt.
  String get systemPrompt => _systemPrompt ?? defaultSystemPrompt;

  /// Initialize the service by loading preferences from storage.
  Future<void> init() async {
    _themeMode = await _loadThemeMode();
    _locale = await _loadLocale();
    _selectedModelPath = await _localPreferencesClient.getString(_selectedModelPathKey);
    _selectedModelName = await _localPreferencesClient.getString(_selectedModelNameKey);
    _contextSize = await _localPreferencesClient.getInt(_contextSizeKey);
    _systemPrompt = await _localPreferencesClient.getString(_systemPromptKey);
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

  /// Persists the user's selected model to local storage.
  Future<void> updateSelectedModel(String path, String name) async {
    _selectedModelPath = path;
    _selectedModelName = name;
    await _localPreferencesClient.setString(_selectedModelPathKey, path);
    await _localPreferencesClient.setString(_selectedModelNameKey, name);
  }

  /// Clears the persisted model selection.
  Future<void> clearSelectedModel() async {
    _selectedModelPath = null;
    _selectedModelName = null;
    await _localPreferencesClient.remove(_selectedModelPathKey);
    await _localPreferencesClient.remove(_selectedModelNameKey);
  }

  /// Persists the context size for model loading.
  Future<void> updateContextSize(int size) async {
    _contextSize = size;
    await _localPreferencesClient.setInt(_contextSizeKey, size);
  }

  /// Persists the system prompt for chat.
  Future<void> updateSystemPrompt(String prompt) async {
    _systemPrompt = prompt;
    await _localPreferencesClient.setString(_systemPromptKey, prompt);
  }
}
