import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/molecules/chat_input.dart';

void main() {
  group('ChatInput', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should render text field and send button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              hintText: 'Enter your message',
            ),
          ),
        ),
      );

      expect(find.text('Enter your message'), findsOneWidget);
    });

    testWidgets('should use default hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('should call onSubmit when send button tapped',
        (tester) async {
      var submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      controller.text = 'Hello';
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(submitCalled, isTrue);
    });

    testWidgets('should call onSubmit when pressing enter', (tester) async {
      var submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.text = 'Hello';
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(submitCalled, isTrue);
    });

    testWidgets('should not call onSubmit for empty text', (tester) async {
      var submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      controller.text = '';
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(submitCalled, isFalse);
    });

    testWidgets('should not call onSubmit for whitespace-only text',
        (tester) async {
      var submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      controller.text = '   ';
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(submitCalled, isFalse);
    });

    testWidgets('should disable text field when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('should disable send button when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              enabled: false,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('should enable controls when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              enabled: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));

      expect(textField.enabled, isTrue);
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('should have correct semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              semanticsId: 'chat-input',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ChatInput));
      expect(semantics.label, startsWith('Chat input'));
    });

    testWidgets('should have ValueKey when semanticsId provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              semanticsId: 'test-id',
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('test-id')), findsOneWidget);
    });

    testWidgets('should have keyed text field and button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
              semanticsId: 'test-id',
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('test-id.textField')), findsOneWidget);
      expect(find.byKey(const ValueKey('test-id.sendButton')), findsOneWidget);
    });

    testWidgets('should allow multiline input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, isNull);
    });

    testWidgets('should use SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should use theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ChatInput), findsOneWidget);

      // Should work with dark theme too
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ChatInput), findsOneWidget);
    });

    testWidgets('should handle rapid submissions', (tester) async {
      var submitCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSubmit: () => submitCount++,
            ),
          ),
        ),
      );

      controller.text = 'Message';
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(submitCount, equals(3));
    });
  });
}
