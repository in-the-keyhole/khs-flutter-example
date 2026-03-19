import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/components/molecules/model_status.dart';
import 'package:khs_flutter_example/src/controllers/llm_controller.dart';
import 'package:khs_flutter_example/src/controllers/locale_controller.dart';
import 'package:khs_flutter_example/src/controllers/model_download_controller.dart';
import 'package:khs_flutter_example/src/controllers/theme_controller.dart';
import 'package:khs_flutter_example/src/localization/app_localizations.dart';
import 'package:khs_flutter_example/src/models/interfaces/control_interface.dart';
import 'package:khs_flutter_example/src/services/llm_completion_service.dart';
import 'package:khs_flutter_example/src/services/llm_models_service.dart';
import 'package:khs_flutter_example/src/services/user_preferences_service.dart';
import 'package:khs_flutter_example/src/views/llm_chat_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_download_llm_client.dart';
import '../mocks/mock_filesystem_client.dart';
import '../mocks/mock_fllama_client.dart';

Future<
    ({
      LlmController llmController,
      ModelDownloadController downloadController,
      UserPreferencesService prefsService,
      ControlInterface controls,
      MockFllamaClient fllamaClient,
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
    controls: controls,
    fllamaClient: fllamaClient,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );

LlmChatView _view({
  required ControlInterface controls,
  required LlmController llmController,
  required ModelDownloadController downloadController,
  required UserPreferencesService prefsService,
}) =>
    LlmChatView(
      controls: controls,
      llmController: llmController,
      modelDownloadController: downloadController,
      preferencesService: prefsService,
      filesystemClient: MockFilesystemClient(),
      modelDownloadClient: MockDownloadLlmClient(),
    );

void main() {
  group('LlmChatView', () {
    testWidgets('renders scaffold with correct key', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('view.llmChat')), findsOneWidget);
    });

    testWidgets('shows ModelStatus widget', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.byType(ModelStatus), findsOneWidget);
    });

    testWidgets('shows "load model first" hint when no model loaded',
        (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Load a model to start chatting'), findsOneWidget);
    });

    testWidgets('chat input TextField is disabled when model not loaded',
        (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows "start chatting" hint after model loaded',
        (tester) async {
      final deps = await _buildDeps();
      await deps.llmController
          .loadModel('/mock/model.gguf', modelName: 'Test Model');

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Start chatting!'), findsOneWidget);
    });

    testWidgets('popup menu contains New Chat and Settings', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('New Chat'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('drawer opens and shows Conversations heading', (tester) async {
      final deps = await _buildDeps();

      await tester.pumpWidget(_wrap(_view(
        controls: deps.controls,
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        prefsService: deps.prefsService,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.text('Conversations'), findsOneWidget);
    });
  });
}
