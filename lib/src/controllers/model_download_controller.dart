import 'package:flutter/foundation.dart';

import '../clients/download_llm_client.dart';
import '../models/model_registry.dart';
import '../models/objects/model_browser_item.dart';

/// Controller that manages model download state across the app.
///
/// Owns the download status and progress for all registry models.
/// Lives at the app level so state persists across navigation.
class ModelDownloadController with ChangeNotifier {
  ModelDownloadController(this._downloadClient);

  final DownloadLlmClient _downloadClient;

  final Map<String, ModelBrowserItem> _modelItems = {};
  bool _isInitialized = false;

  /// Whether the controller has finished its initial disk scan.
  bool get isInitialized => _isInitialized;

  /// All model items, keyed by model ID.
  Map<String, ModelBrowserItem> get modelItems =>
      Map.unmodifiable(_modelItems);

  /// Only models with status == downloaded.
  List<ModelBrowserItem> get downloadedModels => _modelItems.values
      .where((item) => item.status == ModelDownloadStatus.downloaded)
      .toList();

  /// Initialize by scanning disk for existing models.
  Future<void> init() async {
    for (final model in ModelRegistry.models) {
      final exists = await _downloadClient.modelExists(model.filename);
      final localPath = exists
          ? await _downloadClient.getModelPath(model.filename)
          : null;

      _modelItems[model.id] = ModelBrowserItem(
        model: model,
        status: exists
            ? ModelDownloadStatus.downloaded
            : ModelDownloadStatus.notDownloaded,
        localPath: localPath,
      );
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Start downloading a model. Progress updates fire notifyListeners().
  Future<void> downloadModel(ModelInfo model) async {
    final item = _modelItems[model.id];
    if (item == null) return;

    item.status = ModelDownloadStatus.downloading;
    item.downloadProgress = 0.0;
    notifyListeners();

    try {
      final path = await _downloadClient.downloadFile(
        model.downloadUrl,
        filename: model.filename,
        onProgress: (received, total) {
          if (total > 0) {
            item.downloadProgress = received / total;
            notifyListeners();
          }
        },
      );

      if (path != null) {
        item.status = ModelDownloadStatus.downloaded;
        item.localPath = path;
      } else {
        // Cancelled or failed
        item.status = ModelDownloadStatus.notDownloaded;
      }
    } on Exception catch (e) {
      item.status = ModelDownloadStatus.notDownloaded;
      debugPrint('[ModelDownloadController] Download error: $e');
    }
    item.downloadProgress = 0.0;
    notifyListeners();
  }

  /// Cancel the active download.
  void cancelDownload(ModelInfo model) {
    _downloadClient.cancelDownload();
    final item = _modelItems[model.id];
    if (item != null) {
      item.status = ModelDownloadStatus.notDownloaded;
      item.downloadProgress = 0.0;
      notifyListeners();
    }
  }

  /// Delete a downloaded model from disk.
  Future<void> deleteModel(ModelInfo model, String path) async {
    final deleted = await _downloadClient.deleteModel(path);
    if (deleted) {
      final item = _modelItems[model.id];
      if (item != null) {
        item.status = ModelDownloadStatus.notDownloaded;
        item.localPath = null;
        notifyListeners();
      }
    }
  }
}
