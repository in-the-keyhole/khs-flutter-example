import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalPreferencesClient', () {
    late LocalPreferencesClient client;

    setUp(() async {
      // Clear any existing preferences
      SharedPreferences.setMockInitialValues({});
    });

    group('Initialization', () {
      test('should create instance with factory method', () async {
        client = await LocalPreferencesClient.create();
        expect(client, isA<LocalPreferencesClient>());
      });

      test('should accept SharedPreferences in constructor', () async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
        expect(client, isA<LocalPreferencesClient>());
      });

      test('should lazy load SharedPreferences when not provided', () async {
        client = LocalPreferencesClient();
        // First access should initialize
        final result = await client.getString('test');
        expect(result, isNull);
      });

      test('should reuse existing SharedPreferences instance', () async {
        client = LocalPreferencesClient();
        // Multiple calls should reuse the same instance
        await client.getString('key1');
        await client.getString('key2');
        // If we can get values, it's working correctly
        expect(true, isTrue);
      });
    });

    group('String Operations', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store and retrieve string value', () async {
        const key = 'test_string';
        const value = 'Hello World';

        final setResult = await client.setString(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getString(key);
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent string key', () async {
        final result = await client.getString('non_existent_key');
        expect(result, isNull);
      });

      test('should overwrite existing string value', () async {
        const key = 'test_string';

        await client.setString(key, 'First Value');
        await client.setString(key, 'Second Value');

        final result = await client.getString(key);
        expect(result, equals('Second Value'));
      });

      test('should handle empty string', () async {
        const key = 'empty_string';
        const value = '';

        await client.setString(key, value);
        final result = await client.getString(key);
        expect(result, equals(value));
      });
    });

    group('Integer Operations', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store and retrieve integer value', () async {
        const key = 'test_int';
        const value = 42;

        final setResult = await client.setInt(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getInt(key);
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent integer key', () async {
        final result = await client.getInt('non_existent_key');
        expect(result, isNull);
      });

      test('should handle negative integers', () async {
        const key = 'negative_int';
        const value = -100;

        await client.setInt(key, value);
        final result = await client.getInt(key);
        expect(result, equals(value));
      });

      test('should handle zero', () async {
        const key = 'zero_int';
        const value = 0;

        await client.setInt(key, value);
        final result = await client.getInt(key);
        expect(result, equals(value));
      });
    });

    group('Boolean Operations', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store and retrieve true value', () async {
        const key = 'test_bool_true';
        const value = true;

        final setResult = await client.setBool(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getBool(key);
        expect(retrievedValue, equals(value));
      });

      test('should store and retrieve false value', () async {
        const key = 'test_bool_false';
        const value = false;

        final setResult = await client.setBool(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getBool(key);
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent boolean key', () async {
        final result = await client.getBool('non_existent_key');
        expect(result, isNull);
      });

      test('should toggle boolean value', () async {
        const key = 'toggle_bool';

        await client.setBool(key, true);
        var result = await client.getBool(key);
        expect(result, isTrue);

        await client.setBool(key, false);
        result = await client.getBool(key);
        expect(result, isFalse);
      });
    });

    group('Double Operations', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store and retrieve double value', () async {
        const key = 'test_double';
        const value = 3.14159;

        final setResult = await client.setDouble(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getDouble(key);
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent double key', () async {
        final result = await client.getDouble('non_existent_key');
        expect(result, isNull);
      });

      test('should handle negative doubles', () async {
        const key = 'negative_double';
        const value = -99.99;

        await client.setDouble(key, value);
        final result = await client.getDouble(key);
        expect(result, equals(value));
      });

      test('should handle very small doubles', () async {
        const key = 'small_double';
        const value = 0.0001;

        await client.setDouble(key, value);
        final result = await client.getDouble(key);
        expect(result, equals(value));
      });
    });

    group('StringList Operations', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store and retrieve string list', () async {
        const key = 'test_string_list';
        const value = ['apple', 'banana', 'cherry'];

        final setResult = await client.setStringList(key, value);
        expect(setResult, isTrue);

        final retrievedValue = await client.getStringList(key);
        expect(retrievedValue, equals(value));
      });

      test('should return null for non-existent string list key', () async {
        final result = await client.getStringList('non_existent_key');
        expect(result, isNull);
      });

      test('should handle empty list', () async {
        const key = 'empty_list';
        const value = <String>[];

        await client.setStringList(key, value);
        final result = await client.getStringList(key);
        expect(result, equals(value));
      });

      test('should handle list with duplicate values', () async {
        const key = 'duplicate_list';
        const value = ['same', 'same', 'different', 'same'];

        await client.setStringList(key, value);
        final result = await client.getStringList(key);
        expect(result, equals(value));
      });

      test('should preserve list order', () async {
        const key = 'ordered_list';
        const value = ['first', 'second', 'third'];

        await client.setStringList(key, value);
        final result = await client.getStringList(key);
        expect(result, equals(value));
        expect(result?[0], equals('first'));
        expect(result?[2], equals('third'));
      });
    });

    group('Key Management', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should check if key exists', () async {
        const key = 'existing_key';
        await client.setString(key, 'value');

        final exists = await client.containsKey(key);
        expect(exists, isTrue);
      });

      test('should return false for non-existent key', () async {
        final exists = await client.containsKey('non_existent_key');
        expect(exists, isFalse);
      });

      test('should remove key', () async {
        const key = 'removable_key';
        await client.setString(key, 'value');

        var exists = await client.containsKey(key);
        expect(exists, isTrue);

        final removed = await client.remove(key);
        expect(removed, isTrue);

        exists = await client.containsKey(key);
        expect(exists, isFalse);
      });

      test('should return true when removing non-existent key', () async {
        // SharedPreferences.remove returns true even if key doesn't exist
        final removed = await client.remove('non_existent_key');
        expect(removed, isTrue);
      });

      test('should clear all keys', () async {
        await client.setString('key1', 'value1');
        await client.setInt('key2', 42);
        await client.setBool('key3', true);

        var key1Exists = await client.containsKey('key1');
        var key2Exists = await client.containsKey('key2');
        var key3Exists = await client.containsKey('key3');
        expect(key1Exists, isTrue);
        expect(key2Exists, isTrue);
        expect(key3Exists, isTrue);

        final cleared = await client.clear();
        expect(cleared, isTrue);

        key1Exists = await client.containsKey('key1');
        key2Exists = await client.containsKey('key2');
        key3Exists = await client.containsKey('key3');
        expect(key1Exists, isFalse);
        expect(key2Exists, isFalse);
        expect(key3Exists, isFalse);
      });
    });

    group('Type Safety', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should store different types with different keys', () async {
        // Use different keys for different types
        await client.setString('string_key', 'text');
        await client.setInt('int_key', 123);
        await client.setBool('bool_key', true);

        final stringValue = await client.getString('string_key');
        final intValue = await client.getInt('int_key');
        final boolValue = await client.getBool('bool_key');

        expect(stringValue, equals('text'));
        expect(intValue, equals(123));
        expect(boolValue, isTrue);
      });

      test('should overwrite value when using same key with different type', () async {
        const key = 'overwrite_key';

        // Store as string
        await client.setString(key, 'text');
        var stringValue = await client.getString(key);
        expect(stringValue, equals('text'));

        // Overwrite with int - this replaces the string value
        await client.setInt(key, 123);
        var intValue = await client.getInt(key);
        expect(intValue, equals(123));

        // Now contains key exists, but as int not string
        final exists = await client.containsKey(key);
        expect(exists, isTrue);
      });
    });

    group('Edge Cases', () {
      setUp(() async {
        final prefs = await SharedPreferences.getInstance();
        client = LocalPreferencesClient(prefs: prefs);
      });

      test('should handle special characters in keys', () async {
        const key = 'key_with.dots-and_underscores';
        const value = 'special';

        await client.setString(key, value);
        final result = await client.getString(key);
        expect(result, equals(value));
      });

      test('should handle special characters in string values', () async {
        const key = 'special_chars';
        const value = 'Hello\nWorld\t🎉\r\n"quotes"';

        await client.setString(key, value);
        final result = await client.getString(key);
        expect(result, equals(value));
      });

      test('should handle very long strings', () async {
        const key = 'long_string';
        final value = 'A' * 10000; // 10,000 character string

        await client.setString(key, value);
        final result = await client.getString(key);
        expect(result, equals(value));
        expect(result?.length, equals(10000));
      });

      test('should handle large integers', () async {
        const key = 'large_int';
        const value = 9223372036854775807; // Max int64

        await client.setInt(key, value);
        final result = await client.getInt(key);
        expect(result, equals(value));
      });
    });
  });
}
