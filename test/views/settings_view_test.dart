import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/controllers/llm_controller.dart';
import 'package:khs_flutter_example/src/controllers/locale_controller.dart';
import 'package:khs_flutter_example/src/controllers/model_download_controller.dart';
import 'package:khs_flutter_example/src/controllers/theme_controller.dart';
import 'package:khs_flutter_example/src/localization/app_localizations.dart';
import 'package:khs_flutter_example/src/models/interfaces/control_interface.dart';
import 'package:khs_flutter_example/src/services/llm_completion_service.dart';
import 'package:khs_flutter_example/src/services/llm_models_service.dart';
import 'package:khs_flutter_example/src/services/user_preferences_service.dart';
import 'package:khs_flutter_example/src/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_download_llm_client.dart';
import '../mocks/mock_filesystem_client.dart';
import '../mocks/mock_fllama_client.dart';

Future<
    ({
      LlmController llmController,
      ModelDownloadController downloadController,
      UserPreferencesService prefsService,
      ThemeController themeController,
      LocaleController localeController,
      ControlInterface controls,
    })> _buildDeps() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final prefsClient = LocalPreferencesClient(prefs: prefs);
  final prefsService = UserPreferencesService(prefsClient);
  await prefsService.init();

  final fllamaClient = MockFllamaClient();
  final downloadClient = MockDownloadLlmClient();

  final completionService = LlmCompletionService(fllamaClient);
  final modelsService = LlmModelsService(fllamaClient);
  final llmController = LlmController(completionService, modelsService);
  final downloadController = ModelDownloadController(downloadClient);
  await downloadController.init();

  final themeController = ThemeController(prefsService);
  final localeController = LocaleController(prefsService);
  final controls = ControlInterface(
    theme: themeController,
    locale: localeController,
  );

  return (
    llmController: llmController,
    downloadController: downloadController,
    prefsService: prefsService,
    themeController: themeController,
    localeController: localeController,
    controls: controls,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );

SettingsView _view({
  required ControlInterface controls,
  required LlmController llmController,
  required ModelDownloadController downloadController,
  required UserPreferencesService prefsService,
}) =>
    SettingsView(
      controls: controls,
      llmController: llmController,
      modelDownloadController: downloadController,
      preferencesService: prefsService,
      filesystemClient: MockFilesystemClient(),
      modelDownloadClient: MockDownloadLlmClient(),
    );

void main() {
  group('SettingsView', () {
    testWidgets('renders scaffold with correct key', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('view.settings')), findsOneWidget);
    });

    testWidgets('shows Settings app bar title', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows all section headings', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Context Size'), findsOneWidget);
      expect(find.text('System Prompt'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('shows Manage Models button', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Manage Models'), findsOneWidget);
    });

    testWidgets('theme dropdown shows current theme mode', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      // Default theme is system; the dropdown should show "System Theme"
      expect(find.text('System Theme'), findsWidgets);
    });

    testWidgets('changing theme dropdown updates ThemeController',
        (tester) async {
      // Use a tall viewport so all settings sections fit without overflow
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(deps.themeController.mode, equals(ThemeMode.system));

      // Open the theme dropdown by type (key lives on DropdownButton internals)
      final themeDropdown = find.byType(DropdownButton<ThemeMode>);
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();

      // Select Dark Theme from the overlay
      await tester.tap(find.text('Dark Theme').last);
      await tester.pumpAndSettle();

      expect(deps.themeController.mode, equals(ThemeMode.dark));
    });

    testWidgets('changing language dropdown updates LocaleController',
        (tester) async {
      // Use a tall viewport so all settings sections fit without overflow
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(deps.localeController.locale, isNull); // default = system

      // Open the language dropdown
      final langDropdown = find.byType(DropdownButton<Locale?>);
      await tester.tap(langDropdown);
      await tester.pumpAndSettle();

      // Select English explicitly
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      expect(deps.localeController.locale, equals(const Locale('en')));
    });
  });
}
