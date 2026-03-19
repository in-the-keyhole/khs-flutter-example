import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khs_flutter_example/main.dart' as app;

/// Navigate from the chat view to Settings via the popup menu.
Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Flow Integration Tests', () {
    testWidgets('navigating to settings shows settings scaffold',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);

      expect(find.byKey(const ValueKey('view.settings')), findsOneWidget);
      expect(find.byKey(const ValueKey('view.settings.appBar')), findsOneWidget);
    });

    testWidgets('settings view displays all section headings', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);

      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Context Size'), findsOneWidget);
      expect(find.text('System Prompt'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('theme dropdown is present and functional', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);

      final themeDropdown = find.byKey(
        const ValueKey('view.settings.themeDropdown'),
      );
      expect(themeDropdown, findsOneWidget);

      // Open and select Dark Theme
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Dark Theme'), findsWidgets);
      await tester.tap(find.text('Dark Theme').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('language dropdown is present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);

      expect(
        find.byKey(const ValueKey('view.settings.languageDropdown')),
        findsOneWidget,
      );
    });

    testWidgets('context size dropdown is present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);

      expect(
        find.byKey(const ValueKey('view.settings.contextSizeDropdown')),
        findsOneWidget,
      );
    });

    testWidgets('back button returns to chat view', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _openSettings(tester);
      expect(find.byKey(const ValueKey('view.settings')), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('view.llmChat')), findsOneWidget);
    });

    testWidgets('settings persist after navigating away and back',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Go to settings and change theme
      await _openSettings(tester);
      final themeDropdown = find.byKey(
        const ValueKey('view.settings.themeDropdown'),
      );
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark Theme').last);
      await tester.pumpAndSettle();

      // Go back, then back to settings
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await _openSettings(tester);

      // Dark Theme should still be selected
      expect(find.text('Dark Theme'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
