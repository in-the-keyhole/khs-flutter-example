import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/controllers/navigation_controller.dart';

void main() {
  group('NavigationController', () {
    late NavigationController controller;

    setUp(() {
      controller = NavigationController();
    });

    group('Initialization', () {
      test('should create instance', () {
        expect(controller, isA<NavigationController>());
        expect(controller, isA<ChangeNotifier>());
      });

      test('should start with index 0 (AI Chat)', () {
        expect(controller.currentIndex, equals(0));
      });
    });

    group('Navigation', () {
      test('should navigate to index 1', () {
        controller.navigateTo(1);
        expect(controller.currentIndex, equals(1));
      });

      test('should navigate back to index 0', () {
        controller.navigateTo(1);
        controller.navigateTo(0);
        expect(controller.currentIndex, equals(0));
      });

      test('should not notify when navigating to same index', () {
        controller.navigateTo(1);

        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        controller.navigateTo(1);
        expect(notified, isFalse);
      });

      test('should notify listeners when index changes', () {
        var notificationCount = 0;
        controller.addListener(() {
          notificationCount++;
        });

        controller.navigateTo(1);
        expect(notificationCount, equals(1));

        controller.navigateTo(0);
        expect(notificationCount, equals(2));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('should support adding listeners', () {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        controller.navigateTo(1);

        expect(callCount, equals(1));
      });

      test('should support removing listeners', () {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        controller.navigateTo(1);
        expect(callCount, equals(1));

        controller.removeListener(listener);
        controller.navigateTo(0);
        expect(callCount, equals(1)); // Should not increment
      });

      test('should support multiple listeners', () {
        var listener1Called = false;
        var listener2Called = false;

        controller.addListener(() {
          listener1Called = true;
        });
        controller.addListener(() {
          listener2Called = true;
        });

        controller.navigateTo(1);

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid sequential navigation', () {
        controller.navigateTo(1);
        controller.navigateTo(0);
        controller.navigateTo(1);
        controller.navigateTo(0);

        expect(controller.currentIndex, equals(0));
      });

      test('should maintain state after dispose', () {
        controller.navigateTo(1);
        final index = controller.currentIndex;
        controller.dispose();

        // Create new controller
        final newController = NavigationController();
        expect(newController.currentIndex, equals(0)); // Starts fresh at AI Chat
        expect(index, equals(1)); // Old value preserved
      });
    });
  });
}
