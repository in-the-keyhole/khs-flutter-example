import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khs_flutter_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat Flow Integration Tests', () {
    testWidgets('app launches and shows chat scaffold', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const ValueKey('view.llmChat')), findsOneWidget);
    });

    testWidgets('chat view shows model status widget', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.byKey(const ValueKey('view.llmChat.modelStatus')),
        findsOneWidget,
      );
    });

    testWidgets('chat input is present in the view', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.byKey(const ValueKey('view.llmChat.input')),
        findsOneWidget,
      );
    });

    testWidgets('chat app bar is visible with correct key', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.byKey(const ValueKey('view.llmChat.appBar')),
        findsOneWidget,
      );
    });

    testWidgets('popup menu opens and shows navigation items', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('New Chat'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('drawer opens and shows conversations heading', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.text('Conversations'), findsOneWidget);
      expect(find.text('New Chat'), findsOneWidget);
    });

    testWidgets('tapping Load Model navigates to models view', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loadButton = find.text('Load Model');
      if (tester.any(loadButton)) {
        await tester.tap(loadButton.first);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('view.llmModels')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('app handles tablet screen size without crashing',
        (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const ValueKey('view.llmChat')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
