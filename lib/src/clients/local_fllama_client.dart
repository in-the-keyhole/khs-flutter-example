import 'dart:async';

import 'package:fllama/fllama.dart';
import 'package:fllama/fllama_type.dart';

export 'package:fllama/fllama_type.dart' show RoleContent;

/// A client that handles local LLM operations using fllama (llama.cpp binding).
///
/// This client provides a clean abstraction over the fllama package,
/// making it easier to mock for testing and swap implementations if needed.
class LocalFllamaClient {
  LocalFllamaClient({Fllama? fllama}) : _fllama = fllama;

  Fllama? _fllama;
  double? _contextId;
  bool _isLoading = false;
  StreamSubscription<Map<Object?, dynamic>>? _tokenSubscription;

  /// Whether a model is currently loaded and ready for inference.
  bool get isReady => _contextId != null;

  /// Whether a model is currently being loaded.
  bool get isLoading => _isLoading;

  Fllama? _ensureFllama() {
    _fllama ??= Fllama.instance();
    return _fllama;
  }

  /// Loads a model from the given path.
  ///
  /// [modelPath] should be the path to a GGUF format model file.
  /// [onProgress] optional callback for load progress (0.0 to 1.0).
  /// [nCtx] context size (default 512).
  /// [nGpuLayers] number of layers to offload to GPU (0 for CPU only).
  ///
  /// Returns true if the model was loaded successfully.
  Future<bool> loadModel(
    String modelPath, {
    void Function(double progress)? onProgress,
    int nCtx = 512,
    int nGpuLayers = 0,
  }) async {
    final fllama = _ensureFllama();
    if (fllama == null) return false;

    if (_isLoading) return false;
    _isLoading = true;

    try {
      // Listen for load progress if callback provided
      StreamSubscription<Map<Object?, dynamic>>? progressSub;
      if (onProgress != null) {
        progressSub = fllama.onTokenStream?.listen((data) {
          if (data['function'] == 'load_progress') {
            final progress = data['result']?['progress'];
            if (progress is double) {
              onProgress(progress);
            }
          }
        });
      }

      final result = await fllama.initContext(
        modelPath,
        nCtx: nCtx,
        nGpuLayers: nGpuLayers,
        emitLoadProgress: onProgress != null,
      );

      await progressSub?.cancel();

      final contextId = result?['contextId'];
      if (contextId != null) {
        _contextId = (contextId is double) ? contextId : (contextId as num).toDouble();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Generates a completion for the given prompt.
  ///
  /// [prompt] the input text to complete.
  /// [onToken] callback called for each generated token.
  /// [maxTokens] maximum number of tokens to generate (default 256, -1 for unlimited).
  /// [temperature] sampling temperature (default 0.7).
  /// [stopSequences] optional list of sequences that stop generation.
  ///
  /// Returns the complete generated text.
  Future<String> complete(
    String prompt, {
    void Function(String token)? onToken,
    int maxTokens = 256,
    double temperature = 0.7,
    List<String>? stopSequences,
  }) async {
    final fllama = _ensureFllama();
    if (fllama == null || _contextId == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    // Cancel any existing subscription
    await _tokenSubscription?.cancel();

    // Stream tokens in realtime for incremental display
    if (onToken != null) {
      _tokenSubscription = fllama.onTokenStream?.listen((data) {
        if (data['function'] == 'completion') {
          final result = data['result'];
          if (result is Map) {
            final token = result['token'] as String?;
            if (token != null) {
              onToken(token);
            }
          }
        }
      });
    }

    // Start completion — this awaits until the native completion finishes
    final result = await fllama.completion(
      _contextId!,
      prompt: prompt,
      nPredict: maxTokens,
      temperature: temperature,
      stop: stopSequences,
      emitRealtimeCompletion: onToken != null,
    );

    await _tokenSubscription?.cancel();
    _tokenSubscription = null;

    // Return the full generated text from the native result
    return (result?['text'] as String?) ?? '';
  }

  /// Generates a chat completion from a list of messages.
  ///
  /// [messages] list of RoleContent messages (role: "user", "assistant", "system").
  /// [onToken] callback called for each generated token.
  /// [maxTokens] maximum number of tokens to generate.
  /// [temperature] sampling temperature.
  /// [chatTemplate] optional custom chat template.
  Future<String> chat(
    List<RoleContent> messages, {
    void Function(String token)? onToken,
    int maxTokens = 256,
    double temperature = 0.7,
    String? chatTemplate,
  }) async {
    final fllama = _ensureFllama();
    if (fllama == null || _contextId == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    // Use fllama's native getFormattedChat to apply the model's chat template.
    // This properly handles special tokens (e.g. <|im_start|>, <|im_end|>).
    final prompt = await fllama.getFormattedChat(
      _contextId!,
      messages: messages,
      chatTemplate: chatTemplate,
    );

    if (prompt == null || prompt.isEmpty) {
      throw StateError('Failed to format chat messages.');
    }

    // Pass common EOS tokens as stop sequences so the model stops
    // before emitting them (e.g. TinyLlama emits </s>).
    return complete(
      prompt,
      onToken: onToken,
      maxTokens: maxTokens,
      temperature: temperature,
      stopSequences: ['</s>', '<|im_end|>', '<|endoftext|>', '<|eot_id|>'],
    );
  }

  /// Stops any ongoing completion.
  Future<void> stopCompletion() async {
    final fllama = _ensureFllama();
    if (fllama != null && _contextId != null) {
      await fllama.stopCompletion(contextId: _contextId!);
    }
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }

  /// Releases the loaded model and frees resources.
  Future<void> release() async {
    await stopCompletion();

    final fllama = _ensureFllama();
    if (fllama != null && _contextId != null) {
      await fllama.releaseContext(_contextId!);
    }
    _contextId = null;
  }

  /// Releases all loaded models and frees all resources.
  Future<void> releaseAll() async {
    await stopCompletion();

    final fllama = _ensureFllama();
    await fllama?.releaseAllContexts();
    _contextId = null;
  }

  /// Tokenizes a string into token IDs.
  Future<List<int>?> tokenize(String text) async {
    final fllama = _ensureFllama();
    if (fllama == null || _contextId == null) return null;

    final result = await fllama.tokenize(_contextId!, text: text);
    final tokens = result?['tokens'];
    if (tokens is List) {
      return tokens.cast<int>();
    }
    return null;
  }

  /// Converts token IDs back to a string.
  Future<String?> detokenize(List<int> tokens) async {
    final fllama = _ensureFllama();
    if (fllama == null || _contextId == null) return null;

    return await fllama.detokenize(_contextId!, tokens: tokens);
  }

  /// Gets information about the device's CPU.
  Future<Map<String, dynamic>?> getCpuInfo() async {
    final fllama = _ensureFllama();
    if (fllama == null) return null;

    final result = await fllama.getCpuInfo();
    return result?.cast<String, dynamic>();
  }

  /// Gets the SHA256 hash of a file (useful for verifying model integrity).
  Future<String?> getFileSha256(String filePath) async {
    final fllama = _ensureFllama();
    if (fllama == null) return null;

    return await fllama.getFileSHA256(filePath);
  }
}
