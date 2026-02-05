import '../clients/local_fllama_client.dart';

/// A service that provides LLM chat functionality.
///
/// This service wraps the LocalFllamaClient and provides higher-level
/// operations for chat interactions.
class LlmService {
  LlmService(this._client);

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

  /// Generates a chat response for the given prompt.
  ///
  /// [prompt] the user's message.
  /// [onToken] callback for streaming tokens.
  /// [systemPrompt] optional system prompt to prepend.
  /// [maxTokens] maximum tokens to generate.
  /// [temperature] sampling temperature.
  Future<String> chat(
    String prompt, {
    void Function(String token)? onToken,
    String? systemPrompt,
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    if (!isReady) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    // Build a simple chat prompt format
    final fullPrompt = _buildChatPrompt(prompt, systemPrompt);

    return _client.complete(
      fullPrompt,
      onToken: onToken,
      maxTokens: maxTokens,
      temperature: temperature,
      stopSequences: ['User:', '\nUser:', '<|end|>', '<|user|>'],
    );
  }

  /// Stops any ongoing generation.
  Future<void> stopGeneration() async {
    await _client.stopCompletion();
  }

  /// Releases the model and frees resources.
  Future<void> unloadModel() async {
    await _client.release();
    _modelPath = null;
    _modelName = null;
    _loadProgress = 0.0;
  }

  String _buildChatPrompt(String userMessage, String? systemPrompt) {
    final buffer = StringBuffer();

    if (systemPrompt != null) {
      buffer.writeln('System: $systemPrompt');
      buffer.writeln();
    }

    buffer.writeln('User: $userMessage');
    buffer.writeln();
    buffer.write('Assistant:');

    return buffer.toString();
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
