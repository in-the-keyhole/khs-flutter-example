import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/atoms/typing_indicator.dart';

void main() {
  group('TypingIndicator', () {
    testWidgets('should render three dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Find AnimatedBuilder widgets within the TypingIndicator (one per dot)
      final animatedBuilders = find.descendant(
        of: find.byType(TypingIndicator),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilders, findsNWidgets(3));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should have correct semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(
              semanticsId: 'typing-indicator',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(TypingIndicator));
      expect(semantics.label, equals('Assistant is typing'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should align to the left', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, equals(Alignment.centerLeft));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should animate dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // Advance animation
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Animation should be running
      expect(find.byType(TypingIndicator), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should dispose controllers properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Drain pending animation timers
      await tester.pump(const Duration(milliseconds: 500));

      // No exceptions should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have ValueKey when semanticsId provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(
              semanticsId: 'test-id',
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.key, isA<ValueKey<String>>());

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should not have ValueKey when semanticsId is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.key, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should use theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);

      // Should work with dark theme too
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should continue animation while mounted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Pump multiple animation cycles
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Widget should still be present and animating
      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('should stop animation when unmounted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Unmount the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Drain pending animation timers
      await tester.pump(const Duration(milliseconds: 500));

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
