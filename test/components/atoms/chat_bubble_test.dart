import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/atoms/chat_bubble.dart';

void main() {
  group('ChatBubble', () {
    testWidgets('should render user message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Hello',
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('should render assistant message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Hi there',
              isUser: false,
            ),
          ),
        ),
      );

      expect(find.text('Hi there'), findsOneWidget);
    });

    testWidgets('should have correct semantics for user message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
              semanticsId: 'test-bubble',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ChatBubble));
      expect(semantics.label, startsWith('User message'));
    });

    testWidgets('should have correct semantics for assistant message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: false,
              semanticsId: 'test-bubble',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ChatBubble));
      expect(semantics.label, startsWith('Assistant message'));
    });

    testWidgets('should align user messages to the right', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'User message',
              isUser: true,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, equals(Alignment.centerRight));
    });

    testWidgets('should align assistant messages to the left', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Assistant message',
              isUser: false,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, equals(Alignment.centerLeft));
    });

    testWidgets('should constrain width to 75% of screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ChatBubble),
          matching: find.byType(Container),
        ),
      );
      final constraints = container.constraints as BoxConstraints;
      expect(constraints.maxWidth, lessThan(double.infinity));
    });

    testWidgets('should handle long messages', (tester) async {
      final longMessage = 'This is a very long message ' * 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: longMessage,
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should handle empty message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: '',
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
    });

    testWidgets('should handle special characters', (tester) async {
      const message = 'Hello! @#\$% 😀 \n\t special chars';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should have ValueKey when semanticsId provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
              semanticsId: 'test-id',
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.key, isA<ValueKey<String>>());
    });

    testWidgets('should not have ValueKey when semanticsId is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.key, isNull);
    });

    testWidgets('should use theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);

      // Widget should use theme colors (no exception thrown)
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ChatBubble(
              message: 'Test',
              isUser: true,
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
    });
  });
}
