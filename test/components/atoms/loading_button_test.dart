import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/atoms/loading_button.dart';

void main() {
  group('LoadingButton', () {
    testWidgets('should render with child text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {
                pressed = true;
              },
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: null,
              isLoading: true,
              child: Text('Click Me'),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('should disable button when isLoading is true', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {
                pressed = true;
              },
              isLoading: true,
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(pressed, isFalse);
    });

    testWidgets('should disable button when onPressed is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: null,
              child: Text('Click Me'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should apply testId as key on ElevatedButton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              testId: 'test_button',
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      // Key is applied to ElevatedButton
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect((button.key as ValueKey).value, equals('test_button'));
    });

    testWidgets('should apply testId as semantics identifier', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              testId: 'test_button',
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(LoadingButton));
      expect(semantics.identifier, equals('test_button'));
    });

    testWidgets('should be enabled when not loading and onPressed is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              testId: 'test_button',
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should be disabled when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              isLoading: true,
              testId: 'test_button',
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should handle transition from loading to not loading', (WidgetTester tester) async {
      var isLoading = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: LoadingButton(
                  onPressed: () {},
                  isLoading: isLoading,
                  child: const Text('Click Me'),
                ),
              ),
            );
          },
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);

      // Stop loading
      isLoading = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              isLoading: isLoading,
              child: const Text('Click Me'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should have correct loading indicator size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: null,
              isLoading: true,
              child: Text('Click Me'),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.height, equals(20));
      expect(sizedBox.width, equals(20));
    });

    testWidgets('should have correct loading indicator stroke width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: null,
              isLoading: true,
              child: Text('Click Me'),
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(indicator.strokeWidth, equals(2));
    });
  });
}
