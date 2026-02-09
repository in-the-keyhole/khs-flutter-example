import '../clients/local_fllama_client.dart';

/// A service that provides LLM chat completion functionality.
///
/// This service wraps the LocalFllamaClient and provides higher-level
/// operations for chat interactions.
class LlmCompletionService {
  LlmCompletionService(this._client);

  final LocalFllamaClient _client;

  /// Whether a model is currently loaded and ready.
  bool get isReady => _client.isReady;

  /// Generates a chat response for the given messages.
  ///
  /// [messages] the conversation history as RoleContent pairs.
  /// [onToken] callback for streaming tokens.
  /// [maxTokens] maximum tokens to generate.
  /// [temperature] sampling temperature.
  Future<String> chat(
    List<RoleContent> messages, {
    void Function(String token)? onToken,
    int maxTokens = 512,
    double temperature = 0.7,
  }) async {
    if (!isReady) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    return _client.chat(
      messages,
      onToken: onToken,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  /// Stops any ongoing generation.
  Future<void> stopGeneration() async {
    await _client.stopCompletion();
  }
}
