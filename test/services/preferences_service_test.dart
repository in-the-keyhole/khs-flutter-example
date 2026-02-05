import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService service;
    late LocalPreferencesClient client;

    setUp(() async {
      // Clear any existing preferences
      SharedPreferences.setMockInitialValues({});
      client = await LocalPreferencesClient.create();
      service = PreferencesService(client);
    });

    group('Initialization', () {
      test('should not be initialized before init is called', () {
        expect(service.isInitialized, isFalse);
      });

      test('should be initialized after init is called', () async {
        await service.init();
        expect(service.isInitialized, isTrue);
      });

      test('should throw when accessing themeMode before init', () {
        expect(() => service.themeMode, throwsA(isA<Error>()));
      });

      test('should return null when accessing locale before init', () {
        // locale is nullable, so it returns null before init (unlike themeMode which throws)
        expect(service.locale, isNull);
      });
    });

    group('Theme Mode Retrieval', () {
      test('should return system theme when no preference is set', () async {
        await service.init();
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should return light theme when light is stored', () async {
        await client.setString('theme_mode', 'light');
        await service.init();
        expect(service.themeMode, equals(ThemeMode.light));
      });

      test('should return dark theme when dark is stored', () async {
        await client.setString('theme_mode', 'dark');
        await service.init();
        expect(service.themeMode, equals(ThemeMode.dark));
      });

      test('should return system theme when system is stored', () async {
        await client.setString('theme_mode', 'system');
        await service.init();
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should return system theme for invalid string value', () async {
        await client.setString('theme_mode', 'invalid');
        await service.init();
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should return system theme for empty string', () async {
        await client.setString('theme_mode', '');
        await service.init();
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should handle special characters gracefully', () async {
        await client.setString('theme_mode', 'LIGHT');
        await service.init();
        // Should default to system for case-sensitive mismatch
        expect(service.themeMode, equals(ThemeMode.system));
      });
    });

    group('Theme Mode Update', () {
      setUp(() async {
        await service.init();
      });

      test('should save light theme correctly', () async {
        await service.updateThemeMode(ThemeMode.light);
        final stored = await client.getString('theme_mode');
        expect(stored, equals('light'));
      });

      test('should save dark theme correctly', () async {
        await service.updateThemeMode(ThemeMode.dark);
        final stored = await client.getString('theme_mode');
        expect(stored, equals('dark'));
      });

      test('should save system theme correctly', () async {
        await service.updateThemeMode(ThemeMode.system);
        final stored = await client.getString('theme_mode');
        expect(stored, equals('system'));
      });

      test('should overwrite existing theme preference', () async {
        await service.updateThemeMode(ThemeMode.light);
        var stored = await client.getString('theme_mode');
        expect(stored, equals('light'));

        await service.updateThemeMode(ThemeMode.dark);
        stored = await client.getString('theme_mode');
        expect(stored, equals('dark'));
      });

      test('should update cached value', () async {
        expect(service.themeMode, equals(ThemeMode.system));

        await service.updateThemeMode(ThemeMode.dark);
        expect(service.themeMode, equals(ThemeMode.dark));
      });
    });

    group('Round-Trip Operations', () {
      setUp(() async {
        await service.init();
      });

      test('should persist and retrieve light theme', () async {
        await service.updateThemeMode(ThemeMode.light);
        expect(service.themeMode, equals(ThemeMode.light));
      });

      test('should persist and retrieve dark theme', () async {
        await service.updateThemeMode(ThemeMode.dark);
        expect(service.themeMode, equals(ThemeMode.dark));
      });

      test('should persist and retrieve system theme', () async {
        await service.updateThemeMode(ThemeMode.system);
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should handle multiple theme changes', () async {
        await service.updateThemeMode(ThemeMode.light);
        expect(service.themeMode, equals(ThemeMode.light));

        await service.updateThemeMode(ThemeMode.dark);
        expect(service.themeMode, equals(ThemeMode.dark));

        await service.updateThemeMode(ThemeMode.system);
        expect(service.themeMode, equals(ThemeMode.system));
      });
    });

    group('Client Integration', () {
      test('should work with pre-initialized client', () async {
        final prefs = await SharedPreferences.getInstance();
        final customClient = LocalPreferencesClient(prefs: prefs);
        final customService = PreferencesService(customClient);

        await customService.init();
        await customService.updateThemeMode(ThemeMode.dark);
        expect(customService.themeMode, equals(ThemeMode.dark));
      });

      test('should work with lazy-loaded client', () async {
        final lazyClient = LocalPreferencesClient();
        final lazyService = PreferencesService(lazyClient);

        await lazyService.init();
        await lazyService.updateThemeMode(ThemeMode.light);
        expect(lazyService.themeMode, equals(ThemeMode.light));
      });

      test('should share storage with same client instance', () async {
        await service.init();
        await service.updateThemeMode(ThemeMode.dark);

        // Create another service with the same client
        final service2 = PreferencesService(client);
        await service2.init();

        // Should read same value from storage
        expect(service2.themeMode, equals(ThemeMode.dark));
      });

      test('should respect storage key isolation', () async {
        await service.init();

        // Verify theme_mode key doesn't interfere with other keys
        await client.setString('other_key', 'other_value');
        await service.updateThemeMode(ThemeMode.light);

        final themeValue = await client.getString('theme_mode');
        final otherValue = await client.getString('other_key');

        expect(themeValue, equals('light'));
        expect(otherValue, equals('other_value'));
      });
    });

    group('Edge Cases', () {
      setUp(() async {
        await service.init();
      });

      test('should handle rapid sequential updates', () async {
        await service.updateThemeMode(ThemeMode.light);
        await service.updateThemeMode(ThemeMode.dark);
        await service.updateThemeMode(ThemeMode.system);
        await service.updateThemeMode(ThemeMode.light);

        expect(service.themeMode, equals(ThemeMode.light));
      });

      test('should return cached value on multiple reads', () {
        final result1 = service.themeMode;
        final result2 = service.themeMode;
        final result3 = service.themeMode;

        expect(result1, equals(ThemeMode.system));
        expect(result2, equals(ThemeMode.system));
        expect(result3, equals(ThemeMode.system));
      });

      test('should load fresh value after reinitializing', () async {
        await service.updateThemeMode(ThemeMode.dark);
        expect(service.themeMode, equals(ThemeMode.dark));

        // Clear all preferences
        await client.clear();

        // Create new service and init
        final newService = PreferencesService(client);
        await newService.init();
        expect(newService.themeMode, equals(ThemeMode.system));
      });

      test('should persist value that survives reinitialization', () async {
        await service.updateThemeMode(ThemeMode.light);

        // Create new service with same client and init
        final newService = PreferencesService(client);
        await newService.init();

        expect(newService.themeMode, equals(ThemeMode.light));
      });
    });

    group('Default Behavior', () {
      test('should use system theme as default for new installations', () async {
        // Simulate fresh install - no keys set
        await service.init();
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should not write default value to storage', () async {
        await service.init();
        final _ = service.themeMode; // Access the getter

        // Verify nothing was written to storage
        final stored = await client.getString('theme_mode');
        expect(stored, isNull);
      });
    });

    group('Locale', () {
      setUp(() async {
        await service.init();
      });

      test('should return null locale by default', () {
        expect(service.locale, isNull);
      });

      test('should update and retrieve locale', () async {
        await service.updateLocale(const Locale('es'));
        expect(service.locale, equals(const Locale('es')));
      });

      test('should persist locale to storage', () async {
        await service.updateLocale(const Locale('en'));
        final stored = await client.getString('locale');
        expect(stored, equals('en'));
      });

      test('should remove locale from storage when set to null', () async {
        await service.updateLocale(const Locale('es'));
        expect(await client.getString('locale'), equals('es'));

        await service.updateLocale(null);
        expect(await client.getString('locale'), isNull);
        expect(service.locale, isNull);
      });

      test('should load locale from storage on init', () async {
        await client.setString('locale', 'es');

        final newService = PreferencesService(client);
        await newService.init();

        expect(newService.locale, equals(const Locale('es')));
      });
    });
  });
}
