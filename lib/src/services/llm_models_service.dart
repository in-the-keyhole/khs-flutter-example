import '../clients/local_fllama_client.dart';

/// A service that manages LLM model lifecycle.
///
/// Handles loading, unloading, and tracking state of GGUF models.
class LlmModelsService {
  LlmModelsService(this._client);

  final LocalFllamaClient _client;

  String? _modelPath;
  String? _modelName;
  double _loadProgress = 0.0;

  /// Whether a model is currently loaded and ready.
  bool get isReady => _client.isReady;

  /// Whether a model is currently being loaded.
  bool get isLoading => _client.isLoading;

  /// The current model load progress (0.0 to 1.0).
  double get loadProgress => _loadProgress;

  /// The name of the currently loaded model.
  String? get modelName => _modelName;

  /// The path to the currently loaded model.
  String? get modelPath => _modelPath;

  /// Loads a model from the given path.
  ///
  /// [modelPath] path to the GGUF model file.
  /// [modelName] optional display name for the model.
  /// [onProgress] callback for load progress updates.
  /// [nCtx] context size (default 2048 for chat).
  /// [nGpuLayers] layers to offload to GPU (0 for CPU only).
  Future<bool> loadModel(
    String modelPath, {
    String? modelName,
    void Function(double progress)? onProgress,
    int nCtx = 2048,
    int nGpuLayers = 0,
  }) async {
    _modelPath = modelPath;
    _modelName = modelName ?? _extractModelName(modelPath);
    _loadProgress = 0.0;

    final success = await _client.loadModel(
      modelPath,
      nCtx: nCtx,
      nGpuLayers: nGpuLayers,
      onProgress: (progress) {
        _loadProgress = progress;
        onProgress?.call(progress);
      },
    );

    if (!success) {
      _modelPath = null;
      _modelName = null;
    }

    return success;
  }

  /// Releases the model and frees resources.
  Future<void> unloadModel() async {
    await _client.release();
    _modelPath = null;
    _modelName = null;
    _loadProgress = 0.0;
  }

  String _extractModelName(String path) {
    final fileName = path.split('/').last;
    // Remove .gguf extension and clean up
    return fileName
        .replaceAll('.gguf', '')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ');
  }
}
