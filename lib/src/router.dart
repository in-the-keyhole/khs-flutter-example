import 'package:flutter/material.dart';

import 'clients/local_filesystem_client.dart';
import 'clients/download_llm_client.dart';
import 'controllers/llm_controller.dart';
import 'models/interfaces/control_interface.dart';
import 'views/home_view.dart';
import 'views/llm_chat_view.dart';
import 'views/settings_view.dart';

/// Router that handles navigation between views using the NavigationController.
class AppRouter extends StatelessWidget {
  const AppRouter({
    super.key,
    required this.controls,
    required this.llmController,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  final ControlInterface controls;
  final LlmController llmController;
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
          HomeView(controls: controls),
          LlmChatView(
            controls: controls,
            llmController: llmController,
            filesystemClient: filesystemClient,
            modelDownloadClient: modelDownloadClient,
          ),
          SettingsView(controls: controls),
        ],
      ),
    );
  }
}
