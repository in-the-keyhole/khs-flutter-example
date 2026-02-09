import 'package:flutter/material.dart';

import '../services/user_preferences_service.dart';

/// A class that manages the app's locale setting.
///
/// Controllers glue Data Services to Flutter Widgets. The LocaleController
/// uses the UserPreferencesService to store and retrieve locale settings.
class LocaleController with ChangeNotifier {
  LocaleController(this._preferencesService);

  final UserPreferencesService _preferencesService;

  /// The current locale setting. Null means use system locale.
  Locale? get locale => _preferencesService.locale;

  /// Update and persist the Locale based on the user's selection.
  /// Pass null to use system locale.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == _preferencesService.locale) return;

    await _preferencesService.updateLocale(newLocale);
    notifyListeners();
  }
}
