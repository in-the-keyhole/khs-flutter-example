import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/controllers/theme_controller.dart';
import 'package:khs_flutter_example/src/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeController', () {
    late ThemeController controller;
    late PreferencesService service;
    late LocalPreferencesClient client;

    setUp(() async {
      // Clear any existing preferences
      SharedPreferences.setMockInitialValues({});
      client = await LocalPreferencesClient.create();
      service = PreferencesService(client);
      await service.init();
      controller = ThemeController(service);
    });

    group('Initialization', () {
      test('should create instance with service', () {
        expect(controller, isA<ThemeController>());
        expect(controller, isA<ChangeNotifier>());
      });
    });

    group('Theme Mode Access', () {
      test('should return default system theme when no preference exists', () {
        expect(controller.mode, equals(ThemeMode.system));
      });

      test('should return light theme from service', () async {
        await service.updateThemeMode(ThemeMode.light);
        expect(controller.mode, equals(ThemeMode.light));
      });

      test('should return dark theme from service', () async {
        await service.updateThemeMode(ThemeMode.dark);
        expect(controller.mode, equals(ThemeMode.dark));
      });

      test('should return system theme from service', () async {
        await service.updateThemeMode(ThemeMode.system);
        expect(controller.mode, equals(ThemeMode.system));
      });
    });

    group('Update Theme Mode', () {
      test('should update theme from system to light', () async {
        expect(controller.mode, equals(ThemeMode.system));

        await controller.updateMode(ThemeMode.light);
        expect(controller.mode, equals(ThemeMode.light));
      });

      test('should update theme from system to dark', () async {
        expect(controller.mode, equals(ThemeMode.system));

        await controller.updateMode(ThemeMode.dark);
        expect(controller.mode, equals(ThemeMode.dark));
      });

      test('should update theme from light to dark', () async {
        await controller.updateMode(ThemeMode.light);
        expect(controller.mode, equals(ThemeMode.light));

        await controller.updateMode(ThemeMode.dark);
        expect(controller.mode, equals(ThemeMode.dark));
      });

      test('should persist theme to service when updated', () async {
        await controller.updateMode(ThemeMode.dark);

        final persistedTheme = service.themeMode;
        expect(persistedTheme, equals(ThemeMode.dark));
      });

      test('should notify listeners when theme changes', () async {
        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        await controller.updateMode(ThemeMode.light);
        expect(notificationCount, equals(1));

        await controller.updateMode(ThemeMode.dark);
        expect(notificationCount, equals(2));
      });

      test('should not update when null is provided', () async {
        await controller.updateMode(ThemeMode.light);
        expect(controller.mode, equals(ThemeMode.light));

        await controller.updateMode(null);
        expect(controller.mode, equals(ThemeMode.light));
      });

      test('should not notify listeners when null is provided', () async {
        await controller.updateMode(ThemeMode.light);

        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        await controller.updateMode(null);
        expect(notified, isFalse);
      });

      test('should not update when same theme is provided', () async {
        await controller.updateMode(ThemeMode.dark);

        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        await controller.updateMode(ThemeMode.dark);
        expect(notificationCount, equals(0));
      });

      test('should not persist when same theme is provided', () async {
        await controller.updateMode(ThemeMode.light);
        final firstWrite = await client.getString('theme_mode');

        // Update with same theme
        await controller.updateMode(ThemeMode.light);
        final secondWrite = await client.getString('theme_mode');

        expect(firstWrite, equals(secondWrite));
        expect(firstWrite, equals('light'));
      });

      test('should handle rapid sequential updates', () async {
        await controller.updateMode(ThemeMode.light);
        await controller.updateMode(ThemeMode.dark);
        await controller.updateMode(ThemeMode.system);
        await controller.updateMode(ThemeMode.light);

        expect(controller.mode, equals(ThemeMode.light));

        final persistedTheme = service.themeMode;
        expect(persistedTheme, equals(ThemeMode.light));
      });
    });

    group('Theme Mode Getter', () {
      test('should return current theme mode', () {
        expect(controller.mode, isA<ThemeMode>());
      });

      test('should reflect updates immediately', () async {
        expect(controller.mode, equals(ThemeMode.system));

        await controller.updateMode(ThemeMode.dark);
        expect(controller.mode, equals(ThemeMode.dark));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('should support adding listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.updateMode(ThemeMode.light);

        expect(callCount, equals(1));
      });

      test('should support removing listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.updateMode(ThemeMode.light);
        expect(callCount, equals(1));

        controller.removeListener(listener);
        await controller.updateMode(ThemeMode.dark);
        expect(callCount, equals(1)); // Should not increment
      });

      test('should support multiple listeners', () async {
        var listener1Called = false;
        var listener2Called = false;

        controller.addListener(() {
          listener1Called = true;
        });
        controller.addListener(() {
          listener2Called = true;
        });

        await controller.updateMode(ThemeMode.dark);

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);
      });

      test('should notify all listeners in order', () async {
        final callOrder = <int>[];

        controller.addListener(() {
          callOrder.add(1);
        });
        controller.addListener(() {
          callOrder.add(2);
        });
        controller.addListener(() {
          callOrder.add(3);
        });

        await controller.updateMode(ThemeMode.light);

        expect(callOrder, equals([1, 2, 3]));
      });
    });

    group('Integration', () {
      test('should maintain consistency between controller and service',
          () async {
        await controller.updateMode(ThemeMode.dark);
        var serviceTheme = service.themeMode;
        expect(controller.mode, equals(serviceTheme));

        await controller.updateMode(ThemeMode.light);
        serviceTheme = service.themeMode;
        expect(controller.mode, equals(serviceTheme));
      });

      test('should reflect direct service updates', () async {
        expect(controller.mode, equals(ThemeMode.system));

        // Update via service directly
        await service.updateThemeMode(ThemeMode.dark);

        // Controller reads from service, so it sees the change immediately
        expect(controller.mode, equals(ThemeMode.dark));
      });

      test('should work with shared service instance', () async {
        final controller2 = ThemeController(service);

        expect(controller.mode, equals(controller2.mode));

        await controller.updateMode(ThemeMode.dark);

        // Both controllers read from same service
        expect(controller2.mode, equals(ThemeMode.dark));
      });
    });

    group('Edge Cases', () {
      test('should require service init before accessing mode', () async {
        // Create new uninitialized service
        SharedPreferences.setMockInitialValues({});
        final uninitClient = await LocalPreferencesClient.create();
        final uninitService = PreferencesService(uninitClient);
        final uninitController = ThemeController(uninitService);

        // Attempting to access mode before service init throws
        expect(() => uninitController.mode, throwsA(isA<Error>()));

        // After init, it should work
        await uninitService.init();
        expect(uninitController.mode, isA<ThemeMode>());
      });

      test('should handle clearing storage and reinitializing', () async {
        await controller.updateMode(ThemeMode.dark);
        expect(controller.mode, equals(ThemeMode.dark));

        // Clear storage and reinitialize service
        await client.clear();

        // Create fresh service and controller
        final newService = PreferencesService(client);
        await newService.init();
        final newController = ThemeController(newService);

        expect(newController.mode, equals(ThemeMode.system));
      });

      test('should maintain state across controller dispose', () async {
        await controller.updateMode(ThemeMode.light);

        final theme = controller.mode;
        controller.dispose();

        // Create new controller with same service
        final newController = ThemeController(service);

        expect(newController.mode, equals(theme));
      });
    });
  });
}
