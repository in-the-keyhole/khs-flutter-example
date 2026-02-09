import 'package:flutter/foundation.dart';

import '../services/conversation_storage_service.dart';
import '../clients/local_fllama_client.dart';
import '../components/molecules/model_status.dart';
import '../components/organisms/chat_message_list.dart';
import '../models/objects/conversation.dart';
import '../services/llm_completion_service.dart';
import '../services/llm_models_service.dart';
import '../services/user_preferences_service.dart';

/// Controller for LLM chat functionality.
///
/// Manages chat messages, model state, generation status, and saved conversations.
class LlmController with ChangeNotifier {
  LlmController(
    this._completionService,
    this._modelsService, {
    UserPreferencesService? preferencesService,
    ConversationStorageService? conversationStorage,
  })  : _preferencesService = preferencesService,
        _conversationStorage = conversationStorage;

  final LlmCompletionService _completionService;
  final LlmModelsService _modelsService;
  final UserPreferencesService? _preferencesService;
  final ConversationStorageService? _conversationStorage;

  final List<ChatMessage> _messages = [];
  ModelState _modelState = ModelState.notLoaded;
  double _loadProgress = 0.0;
  String? _errorMessage;
  bool _isGenerating = false;
  String _currentResponse = '';

  // Conversation state
  final List<Conversation> _conversations = [];
  String? _currentConversationId;

  /// The list of chat messages.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// The current model state.
  ModelState get modelState => _modelState;

  /// Model load progress (0.0 to 1.0).
  double get loadProgress => _loadProgress;

  /// The name of the loaded model, if any.
  String? get modelName => _modelsService.modelName;

  /// Error message if model loading failed.
  String? get errorMessage => _errorMessage;

  /// Whether the model is currently generating a response.
  bool get isGenerating => _isGenerating;

  /// Whether the model is ready for chat.
  bool get isReady => _modelsService.isReady;

  /// All saved conversations, sorted by most recently updated first.
  List<Conversation> get conversations {
    final sorted = List<Conversation>.from(_conversations);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  /// The ID of the current active conversation.
  String? get currentConversationId => _currentConversationId;

  /// The current active conversation, if any.
  Conversation? get currentConversation {
    if (_currentConversationId == null) return null;
    try {
      return _conversations.firstWhere((c) => c.id == _currentConversationId);
    } catch (_) {
      return null;
    }
  }

  // ============ Conversation Management ============

  /// Loads all saved conversations from storage.
  Future<void> loadConversations() async {
    if (_conversationStorage == null) return;
    final loaded = await _conversationStorage.loadAll();
    _conversations
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  /// Starts a new empty conversation, clearing current messages.
  void newConversation() {
    _messages.clear();
    _currentConversationId = null;
    notifyListeners();
  }

  /// Switches to an existing conversation, loading its messages.
  void switchConversation(String id) {
    final conversation =
        _conversations.cast<Conversation?>().firstWhere((c) => c!.id == id, orElse: () => null);
    if (conversation == null) return;

    _messages
      ..clear()
      ..addAll(conversation.messages);
    _currentConversationId = id;
    notifyListeners();
  }

  /// Renames a conversation.
  Future<void> renameConversation(String id, String title) async {
    final conversation =
        _conversations.cast<Conversation?>().firstWhere((c) => c!.id == id, orElse: () => null);
    if (conversation == null) return;

    conversation.title = title;
    conversation.updatedAt = DateTime.now();
    await _saveConversations();
    notifyListeners();
  }

  /// Deletes a conversation.
  Future<void> deleteConversation(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    await _saveConversations();

    // If we deleted the active conversation, start fresh
    if (_currentConversationId == id) {
      _messages.clear();
      _currentConversationId = null;
    }
    notifyListeners();
  }

  Future<void> _saveConversations() async {
    await _conversationStorage?.saveAll(_conversations);
  }

  /// Auto-saves the current conversation. Creates a new one if needed.
  Future<void> _autoSave() async {
    if (_conversationStorage == null) return;
    if (_messages.isEmpty) return;

    if (_currentConversationId != null) {
      // Update existing conversation
      final conversation = currentConversation;
      if (conversation != null) {
        conversation.messages
          ..clear()
          ..addAll(_messages);
        conversation.updatedAt = DateTime.now();
      }
    } else {
      // Create new conversation from first user message
      final firstUserMessage = _messages.firstWhere(
        (m) => m.isUser,
        orElse: () => const ChatMessage(content: 'New Conversation', isUser: true),
      );
      final title = firstUserMessage.content.length > 40
          ? '${firstUserMessage.content.substring(0, 40)}...'
          : firstUserMessage.content;

      final conversation = Conversation.create(title: title);
      conversation.messages.addAll(_messages);
      _conversations.add(conversation);
      _currentConversationId = conversation.id;
    }

    await _saveConversations();
  }

  // ============ Model Management ============

  /// Load a model from the given path.
  Future<void> loadModel(String modelPath, {String? modelName, int? nCtx}) async {
    if (_modelsService.isLoading) return;

    _modelState = ModelState.loading;
    _loadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    final contextSize = nCtx ?? _preferencesService?.contextSize ?? UserPreferencesService.defaultContextSize;

    try {
      final success = await _modelsService.loadModel(
        modelPath,
        modelName: modelName,
        nCtx: contextSize,
        onProgress: (progress) {
          _loadProgress = progress;
          notifyListeners();
        },
      );

      if (success) {
        _modelState = ModelState.ready;
        // Persist selection so the model auto-loads next session
        final name = _modelsService.modelName;
        if (_preferencesService != null && name != null) {
          await _preferencesService.updateSelectedModel(modelPath, name);
        }
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
    await _modelsService.unloadModel();
    _modelState = ModelState.notLoaded;
    _loadProgress = 0.0;
    await _preferencesService?.clearSelectedModel();
    notifyListeners();
  }

  // ============ Chat ============

  /// Send a message and generate a response.
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
      // Build system prompt from preferences or defaults
      final enhancedSystemPrompt = systemPrompt
          ?? _preferencesService?.systemPrompt
          ?? UserPreferencesService.defaultSystemPrompt;

      // Build RoleContent messages from conversation history
      final roleMessages = <RoleContent>[
        RoleContent(role: 'system', content: enhancedSystemPrompt),
        for (final msg in _messages)
          RoleContent(
            role: msg.isUser ? 'user' : 'assistant',
            content: msg.content,
          ),
      ];

      final response = await _completionService.chat(
        roleMessages,
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
    await _autoSave();
    notifyListeners();
  }

  /// Stop the current generation.
  Future<void> stopGeneration() async {
    if (!_isGenerating) return;

    await _completionService.stopGeneration();

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
    await _autoSave();
    notifyListeners();
  }

  /// Clear all chat messages and start a new conversation.
  void clearMessages() {
    _messages.clear();
    _currentConversationId = null;
    notifyListeners();
  }
}
