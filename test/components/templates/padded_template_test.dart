import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/templates/padded_template.dart';

void main() {
  group('ColumnTemplate', () {
    testWidgets('should render sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Text('Section 1'),
                Text('Section 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
    });

    testWidgets('should handle empty sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [],
            ),
          ),
        ),
      );

      expect(find.byType(ColumnTemplate), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should handle single section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Text('Single section'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Single section'), findsOneWidget);
    });

    testWidgets('should use Column layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Text('A'),
                Text('B'),
              ],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
      expect(column.children.length, equals(2));
    });

    testWidgets('should apply padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Text('Test'),
              ],
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('should have correct semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [Text('Test')],
              semanticsId: 'column-template',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ColumnTemplate));
      expect(semantics.label, startsWith('Column template'));
    });

    testWidgets('should have ValueKey when semanticsId provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [Text('Test')],
              semanticsId: 'test-id',
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.key, isA<ValueKey<String>>());
    });

    testWidgets('should not have ValueKey when semanticsId is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [Text('Test')],
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.key, isNull);
    });

    testWidgets('should handle complex widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Container(
                  height: 100,
                  color: Colors.red,
                  child: const Text('Complex 1'),
                ),
                const Row(
                  children: [
                    Text('Row Item 1'),
                    Text('Row Item 2'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Complex 1'), findsOneWidget);
      expect(find.text('Row Item 1'), findsOneWidget);
      expect(find.text('Row Item 2'), findsOneWidget);
    });

    testWidgets('should preserve section order', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColumnTemplate(
              sections: [
                Text('First'),
                Text('Second'),
                Text('Third'),
              ],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect((column.children[0] as Text).data, equals('First'));
      expect((column.children[1] as Text).data, equals('Second'));
      expect((column.children[2] as Text).data, equals('Third'));
    });

    testWidgets('should handle many sections', (tester) async {
      final sections = List.generate(
        50,
        (index) => Text('Section $index'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ColumnTemplate(
                sections: sections,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ColumnTemplate), findsOneWidget);
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, equals(50));
    });
  });
}
