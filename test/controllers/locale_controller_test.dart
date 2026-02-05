import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/controllers/locale_controller.dart';
import 'package:khs_flutter_example/src/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleController', () {
    late LocaleController controller;
    late PreferencesService service;
    late LocalPreferencesClient client;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      client = await LocalPreferencesClient.create();
      service = PreferencesService(client);
      await service.init();
      controller = LocaleController(service);
    });

    group('Initialization', () {
      test('should create instance with service', () {
        expect(controller, isA<LocaleController>());
        expect(controller, isA<ChangeNotifier>());
      });
    });

    group('Locale Access', () {
      test('should return null locale when no preference exists', () {
        expect(controller.locale, isNull);
      });

      test('should return English locale from service', () async {
        await service.updateLocale(const Locale('en'));
        expect(controller.locale, equals(const Locale('en')));
      });

      test('should return Spanish locale from service', () async {
        await service.updateLocale(const Locale('es'));
        expect(controller.locale, equals(const Locale('es')));
      });
    });

    group('Update Locale', () {
      test('should update locale from null to English', () async {
        expect(controller.locale, isNull);

        await controller.updateLocale(const Locale('en'));
        expect(controller.locale, equals(const Locale('en')));
      });

      test('should update locale from null to Spanish', () async {
        expect(controller.locale, isNull);

        await controller.updateLocale(const Locale('es'));
        expect(controller.locale, equals(const Locale('es')));
      });

      test('should update locale from English to Spanish', () async {
        await controller.updateLocale(const Locale('en'));
        expect(controller.locale, equals(const Locale('en')));

        await controller.updateLocale(const Locale('es'));
        expect(controller.locale, equals(const Locale('es')));
      });

      test('should clear locale when set to null', () async {
        await controller.updateLocale(const Locale('en'));
        expect(controller.locale, equals(const Locale('en')));

        await controller.updateLocale(null);
        expect(controller.locale, isNull);
      });

      test('should persist locale to service when updated', () async {
        await controller.updateLocale(const Locale('es'));

        final persistedLocale = service.locale;
        expect(persistedLocale, equals(const Locale('es')));
      });

      test('should notify listeners when locale changes', () async {
        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        await controller.updateLocale(const Locale('en'));
        expect(notificationCount, equals(1));

        await controller.updateLocale(const Locale('es'));
        expect(notificationCount, equals(2));
      });

      test('should not update when same locale is provided', () async {
        await controller.updateLocale(const Locale('en'));

        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        await controller.updateLocale(const Locale('en'));
        expect(notificationCount, equals(0));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('should support adding listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.updateLocale(const Locale('en'));

        expect(callCount, equals(1));
      });

      test('should support removing listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.updateLocale(const Locale('en'));
        expect(callCount, equals(1));

        controller.removeListener(listener);
        await controller.updateLocale(const Locale('es'));
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

        await controller.updateLocale(const Locale('es'));

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);
      });
    });

    group('Integration', () {
      test('should maintain consistency between controller and service',
          () async {
        await controller.updateLocale(const Locale('es'));
        var serviceLocale = service.locale;
        expect(controller.locale, equals(serviceLocale));

        await controller.updateLocale(const Locale('en'));
        serviceLocale = service.locale;
        expect(controller.locale, equals(serviceLocale));
      });

      test('should reflect direct service updates', () async {
        expect(controller.locale, isNull);

        // Update via service directly
        await service.updateLocale(const Locale('es'));

        // Controller reads from service, so it sees the change immediately
        expect(controller.locale, equals(const Locale('es')));
      });

      test('should work with shared service instance', () async {
        final controller2 = LocaleController(service);

        expect(controller.locale, equals(controller2.locale));

        await controller.updateLocale(const Locale('es'));

        // Both controllers read from same service
        expect(controller2.locale, equals(const Locale('es')));
      });
    });

    group('Edge Cases', () {
      test('should handle rapid sequential updates', () async {
        await controller.updateLocale(const Locale('en'));
        await controller.updateLocale(const Locale('es'));
        await controller.updateLocale(null);
        await controller.updateLocale(const Locale('en'));

        expect(controller.locale, equals(const Locale('en')));

        final persistedLocale = service.locale;
        expect(persistedLocale, equals(const Locale('en')));
      });

      test('should handle clearing storage and reinitializing', () async {
        await controller.updateLocale(const Locale('es'));
        expect(controller.locale, equals(const Locale('es')));

        // Clear storage and reinitialize service
        await client.clear();

        // Create fresh service and controller
        final newService = PreferencesService(client);
        await newService.init();
        final newController = LocaleController(newService);

        expect(newController.locale, isNull);
      });
    });
  });
}
