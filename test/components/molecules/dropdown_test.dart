import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/molecules/dropdown.dart';

void main() {
  group('Dropdown', () {
    group('String Type', () {
      testWidgets('should render with string items', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButton<String>), findsOneWidget);
        expect(find.text('Option 1'), findsOneWidget);
      });

      testWidgets('should call onChanged when selection changes', (WidgetTester tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                ],
                onChanged: (value) {
                  selectedValue = value;
                },
              ),
            ),
          ),
        );

        // Tap to open dropdown
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        // Select Option 2
        await tester.tap(find.text('Option 2').last);
        await tester.pumpAndSettle();

        expect(selectedValue, equals('Option 2'));
      });
    });

    group('Integer Type', () {
      testWidgets('should work with integer type', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<int>(
                value: 1,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('One')),
                  DropdownMenuItem(value: 2, child: Text('Two')),
                  DropdownMenuItem(value: 3, child: Text('Three')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButton<int>), findsOneWidget);
        expect(find.text('One'), findsOneWidget);
      });

      testWidgets('should handle integer selection', (WidgetTester tester) async {
        int? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<int>(
                value: 1,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('One')),
                  DropdownMenuItem(value: 2, child: Text('Two')),
                ],
                onChanged: (value) {
                  selectedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Two').last);
        await tester.pumpAndSettle();

        expect(selectedValue, equals(2));
      });
    });

    group('ThemeMode Type', () {
      testWidgets('should work with ThemeMode enum', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<ThemeMode>(
                value: ThemeMode.system,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButton<ThemeMode>), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
      });

      testWidgets('should handle ThemeMode selection', (WidgetTester tester) async {
        ThemeMode? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<ThemeMode>(
                value: ThemeMode.system,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (value) {
                  selectedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButton<ThemeMode>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Dark').last);
        await tester.pumpAndSettle();

        expect(selectedValue, equals(ThemeMode.dark));
      });
    });

    group('Disabled State', () {
      testWidgets('should be disabled when onChanged is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                ],
                onChanged: null,
              ),
            ),
          ),
        );

        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );

        expect(dropdown.onChanged, isNull);
      });

      testWidgets('should not open when disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                ],
                onChanged: null,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        // Should only find the current value, not the expanded list
        expect(find.text('Option 1'), findsOneWidget);
        expect(find.text('Option 2'), findsNothing);
      });
    });

    group('Semantics', () {
      testWidgets('should apply semantics identifier', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
                semanticsIdentifier: 'test_dropdown',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Dropdown<String>));
        expect(semantics.identifier, equals('test_dropdown'));
      });

      testWidgets('should apply semantics label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
                semanticsLabel: 'Select an option',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Dropdown<String>));
        expect(semantics.label, contains('Select an option'));
      });

      testWidgets('should apply both identifier and label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
                semanticsIdentifier: 'test_dropdown',
                semanticsLabel: 'Select an option',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Dropdown<String>));
        expect(semantics.identifier, equals('test_dropdown'));
        expect(semantics.label, contains('Select an option'));
      });

      testWidgets('should apply key when semanticsIdentifier is provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
                semanticsIdentifier: 'test_dropdown',
              ),
            ),
          ),
        );

        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );

        expect((dropdown.key as ValueKey).value, equals('test_dropdown'));
      });

      testWidgets('should not apply key when semanticsIdentifier is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );

        expect(dropdown.key, isNull);
      });

      testWidgets('should work without semantic properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Option 1',
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        // Should render without semantic properties
        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle single item', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: 'Only Option',
                items: const [
                  DropdownMenuItem(value: 'Only Option', child: Text('Only Option')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Only Option'), findsOneWidget);
      });

      testWidgets('should handle many items', (WidgetTester tester) async {
        final items = List.generate(
          20,
          (i) => DropdownMenuItem(value: i, child: Text('Item $i')),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<int>(
                value: 0,
                items: items,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Item 0'), findsOneWidget);

        // Open dropdown
        await tester.tap(find.byType(DropdownButton<int>));
        await tester.pumpAndSettle();

        // Dropdown should be open with multiple items visible
        // Note: Not all items may be visible due to scrolling constraints
        expect(find.text('Item 0'), findsWidgets);
      });

      testWidgets('should update when value changes', (WidgetTester tester) async {
        String currentValue = 'Option 1';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Dropdown<String>(
                    value: currentValue,
                    items: const [
                      DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                      DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        currentValue = value!;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        );

        expect(find.text('Option 1'), findsOneWidget);

        // Change value
        currentValue = 'Option 2';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Dropdown<String>(
                value: currentValue,
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Option 2'), findsOneWidget);
      });
    });
  });
}
