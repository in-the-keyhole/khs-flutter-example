import 'package:flutter/material.dart';

import '../clients/local_filesystem_client.dart';
import '../clients/download_llm_client.dart';
import '../components/organisms/model_browser.dart';
import '../controllers/llm_controller.dart';
import '../localization/app_localizations.dart';
import '../models/model_registry.dart';

/// View for browsing, downloading, and selecting LLM models.
class LlmModelsView extends StatefulWidget {
  const LlmModelsView({
    super.key,
    required this.llmController,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  static const routeName = '/llm-models';

  final LlmController llmController;
  final LocalFilesystemClient filesystemClient;
  final DownloadLlmClient modelDownloadClient;

  @override
  State<LlmModelsView> createState() => _LlmModelsViewState();
}

class _LlmModelsViewState extends State<LlmModelsView> {
  final Map<String, ModelBrowserItem> _modelItems = {};
  bool _isLoadingModels = true;

  @override
  void initState() {
    super.initState();
    _initModelItems();
  }

  Future<void> _initModelItems() async {
    setState(() => _isLoadingModels = true);

    for (final model in ModelRegistry.models) {
      final exists =
          await widget.modelDownloadClient.modelExists(model.filename);
      final localPath = exists
          ? await widget.modelDownloadClient.getModelPath(model.filename)
          : null;

      _modelItems[model.id] = ModelBrowserItem(
        model: model,
        status: exists
            ? ModelDownloadStatus.downloaded
            : ModelDownloadStatus.notDownloaded,
        localPath: localPath,
      );
    }

    if (mounted) {
      setState(() => _isLoadingModels = false);
    }
  }

  Future<void> _pickFromDevice() async {
    final localizations = AppLocalizations.of(context)!;

    final path = await widget.filesystemClient.pickFile(
      allowedExtensions: ['gguf'],
      dialogTitle: localizations.llmLoadModelTitle,
    );

    if (path != null && mounted) {
      final modelName = widget.filesystemClient.getFileName(path);
      widget.llmController.loadModel(path, modelName: modelName);
      Navigator.of(context).pop(true); // Return true to indicate model loaded
    }
  }

  Future<void> _downloadModel(ModelInfo model) async {
    debugPrint('[Download] Starting download for ${model.name}');
    debugPrint('[Download] URL: ${model.downloadUrl}');

    final item = _modelItems[model.id];
    if (item == null) {
      debugPrint('[Download] ERROR: item is null for ${model.id}');
      return;
    }

    debugPrint('[Download] Setting status to downloading');
    setState(() {
      item.status = ModelDownloadStatus.downloading;
      item.downloadProgress = 0.0;
    });

    try {
      debugPrint('[Download] Calling downloadFile...');
      final path = await widget.modelDownloadClient.downloadFile(
        model.downloadUrl,
        filename: model.filename,
        onProgress: (received, total) {
          if (mounted && total > 0) {
            debugPrint('[Download] Progress: $received / $total');
            setState(() {
              item.downloadProgress = received / total;
            });
          }
        },
      );

      debugPrint('[Download] downloadFile returned: $path');
      if (mounted) {
        setState(() {
          if (path != null) {
            item.status = ModelDownloadStatus.downloaded;
            item.localPath = path;
          } else {
            item.status = ModelDownloadStatus.notDownloaded;
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[Download] ERROR: $e');
      debugPrint('[Download] Stack: $stackTrace');
      if (mounted) {
        setState(() {
          item.status = ModelDownloadStatus.notDownloaded;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  void _cancelDownload(ModelInfo model) {
    widget.modelDownloadClient.cancelDownload();
    final item = _modelItems[model.id];
    if (item != null && mounted) {
      setState(() {
        item.status = ModelDownloadStatus.notDownloaded;
        item.downloadProgress = 0.0;
      });
    }
  }

  Future<void> _deleteModel(ModelInfo model, String path) async {
    final deleted = await widget.modelDownloadClient.deleteModel(path);
    if (deleted && mounted) {
      final item = _modelItems[model.id];
      if (item != null) {
        setState(() {
          item.status = ModelDownloadStatus.notDownloaded;
          item.localPath = null;
        });
      }
    }
  }

  void _selectModel(ModelInfo model, String path) {
    widget.llmController.loadModel(path, modelName: model.name);
    Navigator.of(context).pop(true); // Return true to indicate model loaded
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      identifier: 'view.llmModels',
      label: 'Page',
      child: Scaffold(
        key: const ValueKey('view.llmModels'),
        appBar: AppBar(
          key: const ValueKey('view.llmModels.appBar'),
          title: Text(localizations.llmModelBrowserTitle),
        ),
        body: Column(
          children: [
            // Pick from device option
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(localizations.llmPickFromDevice),
              subtitle: Text(localizations.llmPickFromDeviceSubtitle),
              onTap: _pickFromDevice,
            ),
            const Divider(height: 1),
            // Model browser list
            Expanded(
              child: _isLoadingModels
                  ? const Center(child: CircularProgressIndicator())
                  : ModelBrowser(
                      items: _modelItems.values.toList(),
                      onDownload: _downloadModel,
                      onSelect: _selectModel,
                      onCancel: _cancelDownload,
                      onDelete: _deleteModel,
                      semanticsId: 'view.llmModels.browser',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
