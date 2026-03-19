import '../../models/model_registry.dart';

/// Status of a model in the browser.
enum ModelDownloadStatus { notDownloaded, downloading, downloaded }

/// State for a model in the browser list.
class ModelBrowserItem {
  ModelBrowserItem({
    required this.model,
    this.status = ModelDownloadStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.localPath,
  });

  final ModelInfo model;
  ModelDownloadStatus status;
  double downloadProgress;
  String? localPath;
}
