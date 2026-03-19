import 'package:flutter/material.dart';

import '../clients/download_llm_client.dart';
import '../clients/local_filesystem_client.dart';
import '../components/organisms/model_browser.dart';
import '../controllers/llm_controller.dart';
import '../controllers/model_download_controller.dart';
import '../localization/app_localizations.dart';
import '../models/model_registry.dart';

/// View for browsing, downloading, and selecting LLM models.
class LlmModelsView extends StatefulWidget {
  const LlmModelsView({
    super.key,
    required this.llmController,
    required this.filesystemClient,
    required this.modelDownloadClient,
    required this.modelDownloadController,
  });

  static const routeName = '/llm-models';

  final LlmController llmController;
  final LocalFilesystemClient filesystemClient;
  final DownloadLlmClient modelDownloadClient;
  final ModelDownloadController modelDownloadController;

  @override
  State<LlmModelsView> createState() => _LlmModelsViewState();
}

class _LlmModelsViewState extends State<LlmModelsView> {
  Future<void> _pickFromDevice() async {
    final localizations = AppLocalizations.of(context)!;

    final path = await widget.filesystemClient.pickFile(
      allowedExtensions: ['gguf'],
      dialogTitle: localizations.llmLoadModelTitle,
    );

    if (path != null && mounted) {
      final modelName = widget.filesystemClient.getFileName(path);
      widget.llmController.loadModel(path, modelName: modelName);
      Navigator.of(context).pop(true);
    }
  }

  void _selectModel(ModelInfo model, String path) {
    widget.llmController.loadModel(path, modelName: model.name);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      identifier: 'view.llmModels',
      label: 'Page',
      child: ListenableBuilder(
        listenable: widget.modelDownloadController,
        builder: (context, _) {
          final items =
              widget.modelDownloadController.modelItems.values.toList();
          final isLoading = !widget.modelDownloadController.isInitialized;

          return Scaffold(
            key: const ValueKey('view.llmModels'),
            appBar: AppBar(
              key: const ValueKey('view.llmModels.appBar'),
              title: Text(localizations.llmModelBrowserTitle),
            ),
            body: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text(localizations.llmPickFromDevice),
                  subtitle: Text(localizations.llmPickFromDeviceSubtitle),
                  onTap: _pickFromDevice,
                ),
                const Divider(height: 1),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ModelBrowser(
                          items: items,
                          onDownload:
                              widget.modelDownloadController.downloadModel,
                          onSelect: _selectModel,
                          onCancel:
                              widget.modelDownloadController.cancelDownload,
                          onDelete:
                              widget.modelDownloadController.deleteModel,
                          semanticsId: 'view.llmModels.browser',
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
