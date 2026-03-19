import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_preferences_client.dart';
import 'package:khs_flutter_example/src/components/organisms/model_browser.dart';
import 'package:khs_flutter_example/src/controllers/llm_controller.dart';
import 'package:khs_flutter_example/src/controllers/model_download_controller.dart';
import 'package:khs_flutter_example/src/localization/app_localizations.dart';
import 'package:khs_flutter_example/src/services/llm_completion_service.dart';
import 'package:khs_flutter_example/src/services/llm_models_service.dart';
import 'package:khs_flutter_example/src/services/user_preferences_service.dart';
import 'package:khs_flutter_example/src/views/llm_models_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_download_llm_client.dart';
import '../mocks/mock_filesystem_client.dart';
import '../mocks/mock_fllama_client.dart';

Future<
    ({
      LlmController llmController,
      ModelDownloadController downloadController,
      MockDownloadLlmClient downloadClient,
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

  return (
    llmController: llmController,
    downloadController: downloadController,
    downloadClient: downloadClient,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );

LlmModelsView _view({
  required LlmController llmController,
  required ModelDownloadController downloadController,
  required MockDownloadLlmClient downloadClient,
}) =>
    LlmModelsView(
      llmController: llmController,
      filesystemClient: MockFilesystemClient(),
      modelDownloadClient: downloadClient,
      modelDownloadController: downloadController,
    );

void main() {
  group('LlmModelsView', () {
    testWidgets('renders scaffold with correct key', (tester) async {
      final deps = await _buildDeps();
      await deps.downloadController.init();

      await tester.pumpWidget(_wrap(_view(
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        downloadClient: deps.downloadClient,
      )));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('view.llmModels')), findsOneWidget);
    });

    testWidgets('shows loading spinner when not initialized', (tester) async {
      final deps = await _buildDeps();
      // Do NOT call init() so isInitialized remains false

      await tester.pumpWidget(_wrap(_view(
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        downloadClient: deps.downloadClient,
      )));
      await tester.pump(); // single frame – don't settle so spinner is visible

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows ModelBrowser after initialization', (tester) async {
      final deps = await _buildDeps();
      await deps.downloadController.init();

      await tester.pumpWidget(_wrap(_view(
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        downloadClient: deps.downloadClient,
      )));
      await tester.pumpAndSettle();

      expect(find.byType(ModelBrowser), findsOneWidget);
    });

    testWidgets('shows "Pick from device" list tile', (tester) async {
      final deps = await _buildDeps();
      await deps.downloadController.init();

      await tester.pumpWidget(_wrap(_view(
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        downloadClient: deps.downloadClient,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Pick from device'), findsOneWidget);
    });

    testWidgets('shows correct app bar title', (tester) async {
      final deps = await _buildDeps();
      await deps.downloadController.init();

      await tester.pumpWidget(_wrap(_view(
        llmController: deps.llmController,
        downloadController: deps.downloadController,
        downloadClient: deps.downloadClient,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Available Models'), findsOneWidget);
    });
  });
}
