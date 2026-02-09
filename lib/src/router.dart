import 'package:flutter/material.dart';

import 'clients/local_filesystem_client.dart';
import 'clients/download_llm_client.dart';
import 'controllers/llm_controller.dart';
import 'controllers/model_download_controller.dart';
import 'models/interfaces/control_interface.dart';
import 'services/user_preferences_service.dart';
import 'views/llm_chat_view.dart';
import 'views/settings_view.dart';

/// Router that handles navigation between views using the NavigationController.
class AppRouter extends StatelessWidget {
  const AppRouter({
    super.key,
    required this.controls,
    required this.llmController,
    required this.modelDownloadController,
    required this.preferencesService,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  final ControlInterface controls;
  final LlmController llmController;
  final ModelDownloadController modelDownloadController;
  final UserPreferencesService preferencesService;
  final LocalFilesystemClient filesystemClient;
  final DownloadLlmClient modelDownloadClient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'view.router',
      label: 'View router',
      child: IndexedStack(
        key: const ValueKey('view.router.indexedStack'),
        index: controls.navigation.currentIndex,
        children: [
          LlmChatView(
            controls: controls,
            llmController: llmController,
            modelDownloadController: modelDownloadController,
            filesystemClient: filesystemClient,
            modelDownloadClient: modelDownloadClient,
          ),
          SettingsView(
            controls: controls,
            llmController: llmController,
            modelDownloadController: modelDownloadController,
            preferencesService: preferencesService,
            filesystemClient: filesystemClient,
            modelDownloadClient: modelDownloadClient,
          ),
        ],
      ),
    );
  }
}
