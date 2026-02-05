import 'package:flutter/foundation.dart';

import '../components/molecules/model_status.dart';
import '../components/organisms/chat_message_list.dart';
import '../services/kb_service.dart';
import '../services/llm_service.dart';

/// Controller for LLM chat functionality.
///
/// Manages chat messages, model state, and generation status.
/// Optionally integrates with a knowledge base service for context injection.
class LlmController with ChangeNotifier {
  LlmController(this._llmService, {KbService? kbService}) : _kbService = kbService;

  final LlmService _llmService;
  final KbService? _kbService;

  final List<ChatMessage> _messages = [];
  ModelState _modelState = ModelState.notLoaded;
  double _loadProgress = 0.0;
  String? _errorMessage;
  bool _isGenerating = false;
  String _currentResponse = '';

  /// The list of chat messages.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// The current model state.
  ModelState get modelState => _modelState;

  /// Model load progress (0.0 to 1.0).
  double get loadProgress => _loadProgress;

  /// The name of the loaded model, if any.
  String? get modelName => _llmService.modelName;

  /// Error message if model loading failed.
  String? get errorMessage => _errorMessage;

  /// Whether the model is currently generating a response.
  bool get isGenerating => _isGenerating;

  /// Whether the model is ready for chat.
  bool get isReady => _llmService.isReady;

  /// Load a model from the given path.
  Future<void> loadModel(String modelPath, {String? modelName}) async {
    if (_llmService.isLoading) return;

    _modelState = ModelState.loading;
    _loadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _llmService.loadModel(
        modelPath,
        modelName: modelName,
        onProgress: (progress) {
          _loadProgress = progress;
          notifyListeners();
        },
      );

      if (success) {
        _modelState = ModelState.ready;
      } else {
        _modelState = ModelState.error;
        _errorMessage = 'Failed to load model';
      }
    } catch (e) {
      _modelState = ModelState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Unload the current model.
  Future<void> unloadModel() async {
    await _llmService.unloadModel();
    _modelState = ModelState.notLoaded;
    _loadProgress = 0.0;
    notifyListeners();
  }

  /// Send a message and generate a response.
  ///
  /// If a knowledge base service is configured, relevant context will be
  /// automatically injected into the system prompt.
  Future<void> sendMessage(String content, {String? systemPrompt}) async {
    if (!isReady || _isGenerating) return;
    if (content.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      content: content.trim(),
      isUser: true,
      id: 'user_${_messages.length}',
    ));
    notifyListeners();

    // Start generating
    _isGenerating = true;
    _currentResponse = '';
    notifyListeners();

    try {
      // Build enhanced system prompt with KB context if available
      String? enhancedSystemPrompt = systemPrompt;
      if (_kbService != null) {
        enhancedSystemPrompt = await _kbService.buildSystemPromptWithContext(
          systemPrompt ?? 'You are a helpful assistant.',
          content,
        );
      }

      final response = await _llmService.chat(
        content,
        systemPrompt: enhancedSystemPrompt,
        onToken: (token) {
          _currentResponse += token;
          notifyListeners();
        },
      );

      // Add assistant message
      _messages.add(ChatMessage(
        content: response.trim(),
        isUser: false,
        id: 'assistant_${_messages.length}',
      ));
    } catch (e) {
      // Add error message
      _messages.add(ChatMessage(
        content: 'Error: ${e.toString()}',
        isUser: false,
        id: 'error_${_messages.length}',
      ));
    }

    _isGenerating = false;
    _currentResponse = '';
    notifyListeners();
  }

  /// Stop the current generation.
  Future<void> stopGeneration() async {
    if (!_isGenerating) return;

    await _llmService.stopGeneration();

    // Add partial response if any
    if (_currentResponse.isNotEmpty) {
      _messages.add(ChatMessage(
        content: '${_currentResponse.trim()} [stopped]',
        isUser: false,
        id: 'assistant_${_messages.length}',
      ));
    }

    _isGenerating = false;
    _currentResponse = '';
    notifyListeners();
  }

  /// Clear all chat messages.
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
