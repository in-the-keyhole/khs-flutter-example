import 'package:shared_preferences/shared_preferences.dart';

/// A client that handles local preferences operations using shared_preferences.
///
/// This client provides a clean abstraction over the shared_preferences package,
/// making it easier to mock for testing and swap implementations if needed.
class LocalPreferencesClient {
  LocalPreferencesClient({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  Future<SharedPreferences>? _prefsLoading;

  Future<SharedPreferences> _ensurePrefs() {
    final existing = _prefs;
    if (existing != null) {
      return Future.value(existing);
    }

    final loading = _prefsLoading;
    if (loading != null) {
      return loading;
    }

    final future = SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      return prefs;
    });
    _prefsLoading = future;
    return future;
  }

  /// Factory method to create an instance of LocalPreferencesClient.
  static Future<LocalPreferencesClient> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPreferencesClient(prefs: prefs);
  }

  /// Retrieves a string value from local storage.
  Future<String?> getString(String key) async {
    return (await _ensurePrefs()).getString(key);
  }

  /// Stores a string value in local storage.
  Future<bool> setString(String key, String value) async {
    return (await _ensurePrefs()).setString(key, value);
  }

  /// Retrieves an integer value from local storage.
  Future<int?> getInt(String key) async {
    return (await _ensurePrefs()).getInt(key);
  }

  /// Stores an integer value in local storage.
  Future<bool> setInt(String key, int value) async {
    return (await _ensurePrefs()).setInt(key, value);
  }

  /// Retrieves a boolean value from local storage.
  Future<bool?> getBool(String key) async {
    return (await _ensurePrefs()).getBool(key);
  }

  /// Stores a boolean value in local storage.
  Future<bool> setBool(String key, bool value) async {
    return (await _ensurePrefs()).setBool(key, value);
  }

  /// Retrieves a double value from local storage.
  Future<double?> getDouble(String key) async {
    return (await _ensurePrefs()).getDouble(key);
  }

  /// Stores a double value in local storage.
  Future<bool> setDouble(String key, double value) async {
    return (await _ensurePrefs()).setDouble(key, value);
  }

  /// Retrieves a list of strings from local storage.
  Future<List<String>?> getStringList(String key) async {
    return (await _ensurePrefs()).getStringList(key);
  }

  /// Stores a list of strings in local storage.
  Future<bool> setStringList(String key, List<String> value) async {
    return (await _ensurePrefs()).setStringList(key, value);
  }

  /// Removes a value from local storage.
  Future<bool> remove(String key) async {
    return (await _ensurePrefs()).remove(key);
  }

  /// Clears all values from local storage.
  Future<bool> clear() async {
    return (await _ensurePrefs()).clear();
  }

  /// Checks if a key exists in local storage.
  Future<bool> containsKey(String key) async {
    return (await _ensurePrefs()).containsKey(key);
  }
}
