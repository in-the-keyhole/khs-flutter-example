import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/atoms/section_heading.dart';

void main() {
  group('SectionHeading', () {
    testWidgets('should render with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading'),
          ),
        ),
      );

      expect(find.text('Test Heading'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should have correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, equals(18));
    });

    testWidgets('should have bold font weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should apply semantics identifier', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading', semanticsId: 'test_heading'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(SectionHeading));
      expect(semantics.identifier, equals('test_heading'));
    });

    testWidgets('should have correct semantics label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('My Section', semanticsId: 'test_heading'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(SectionHeading));
      expect(semantics.label, contains('Heading: My Section'));
    });

    testWidgets('should apply key when semanticsId is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading', semanticsId: 'test_heading'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect((text.key as ValueKey).value, equals('test_heading'));
    });

    testWidgets('should not apply key when semanticsId is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading('Test Heading'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.key, isNull);
    });

    testWidgets('should handle empty string text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading(''),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, equals(''));
    });

    testWidgets('should handle long text', (WidgetTester tester) async {
      const longText = 'This is a very long heading that might wrap to multiple lines';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading(longText),
          ),
        ),
      );

      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('should handle special characters', (WidgetTester tester) async {
      const specialText = 'Heading with "quotes" & symbols!';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading(specialText),
          ),
        ),
      );

      expect(find.text(specialText), findsOneWidget);
    });

    testWidgets('should handle unicode characters', (WidgetTester tester) async {
      const unicodeText = 'Título en Español 🎉';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeading(unicodeText),
          ),
        ),
      );

      expect(find.text(unicodeText), findsOneWidget);
    });

    testWidgets('should render multiple instances independently', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SectionHeading('First Heading', semanticsId: 'first'),
                SectionHeading('Second Heading', semanticsId: 'second'),
                SectionHeading('Third Heading', semanticsId: 'third'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First Heading'), findsOneWidget);
      expect(find.text('Second Heading'), findsOneWidget);
      expect(find.text('Third Heading'), findsOneWidget);
      expect(find.byType(SectionHeading), findsNWidgets(3));
    });
  });
}
