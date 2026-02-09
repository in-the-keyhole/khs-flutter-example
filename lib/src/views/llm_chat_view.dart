import 'package:flutter/material.dart';

import '../clients/local_filesystem_client.dart';
import '../clients/download_llm_client.dart';
import '../components/molecules/chat_input.dart';
import '../components/molecules/model_status.dart';
import '../components/organisms/chat_message_list.dart';
import '../controllers/llm_controller.dart';
import '../controllers/model_download_controller.dart';
import '../localization/app_localizations.dart';
import '../models/interfaces/control_interface.dart';
import '../services/user_preferences_service.dart';
import 'llm_models_view.dart';
import 'settings_view.dart';

/// LLM Chat view with local model inference.
class LlmChatView extends StatefulWidget {
  const LlmChatView({
    super.key,
    required this.controls,
    required this.llmController,
    required this.modelDownloadController,
    required this.preferencesService,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  static const routeName = '/llm-chat';

  final ControlInterface controls;
  final LlmController llmController;
  final ModelDownloadController modelDownloadController;
  final UserPreferencesService preferencesService;
  final LocalFilesystemClient filesystemClient;
  final DownloadLlmClient modelDownloadClient;

  @override
  State<LlmChatView> createState() => _LlmChatViewState();
}

class _LlmChatViewState extends State<LlmChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.llmController.sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _handleLoadModel() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LlmModelsView(
          llmController: widget.llmController,
          filesystemClient: widget.filesystemClient,
          modelDownloadClient: widget.modelDownloadClient,
          modelDownloadController: widget.modelDownloadController,
        ),
      ),
    );
  }

  void _showRenameDialog(String id, String currentTitle) {
    final localizations = AppLocalizations.of(context)!;
    final renameController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.renameDialogTitle),
        content: TextField(
          controller: renameController,
          autofocus: true,
          onSubmitted: (_) {
            final newTitle = renameController.text.trim();
            if (newTitle.isNotEmpty) {
              widget.llmController.renameConversation(id, newTitle);
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              final newTitle = renameController.text.trim();
              if (newTitle.isNotEmpty) {
                widget.llmController.renameConversation(id, newTitle);
              }
              Navigator.of(context).pop();
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    ).then((_) => renameController.dispose());
  }

  void _showDeleteDialog(String id) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteConversation),
        content: Text(localizations.deleteConversationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.llmController.deleteConversation(id);
              Navigator.of(context).pop();
            },
            child: Text(localizations.deleteConversation),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final localizations = AppLocalizations.of(context)!;
    final conversations = widget.llmController.conversations;
    final currentId = widget.llmController.currentConversationId;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.conversationsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      widget.llmController.newConversation();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add),
                    label: Text(localizations.newChat),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Text(
                        localizations.llmStartChatting,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final isActive = conversation.id == currentId;

                        return ListTile(
                          selected: isActive,
                          title: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _formatTimestamp(conversation.updatedAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            widget.llmController
                                .switchConversation(conversation.id);
                            Navigator.of(context).pop();
                            _scrollToBottom();
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'rename':
                                  _showRenameDialog(
                                      conversation.id, conversation.title);
                                  break;
                                case 'delete':
                                  _showDeleteDialog(conversation.id);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rename',
                                child:
                                    Text(localizations.renameConversation),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child:
                                    Text(localizations.deleteConversation),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      identifier: 'view.llmChat',
      label: 'Page',
      child: Scaffold(
        key: const ValueKey('view.llmChat'),
        drawer: _buildDrawer(),
        appBar: AppBar(
          key: const ValueKey('view.llmChat.appBar'),
          title: Text(localizations.llmChatTitle),
          actions: [
            if (widget.llmController.isGenerating)
              IconButton(
                icon: const Icon(Icons.stop),
                tooltip: localizations.llmStopGeneration,
                onPressed: widget.llmController.stopGeneration,
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'new':
                    widget.llmController.newConversation();
                    break;
                  case 'unload':
                    widget.llmController.unloadModel();
                    break;
                  case 'settings':
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsView(
                          controls: widget.controls,
                          llmController: widget.llmController,
                          modelDownloadController:
                              widget.modelDownloadController,
                          preferencesService: widget.preferencesService,
                          filesystemClient: widget.filesystemClient,
                          modelDownloadClient: widget.modelDownloadClient,
                        ),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'new',
                  child: Text(localizations.newChat),
                ),
                if (widget.llmController.isReady)
                  PopupMenuItem(
                    value: 'unload',
                    child: Text(localizations.llmUnloadModel),
                  ),
                PopupMenuItem(
                  value: 'settings',
                  child: Text(localizations.settingsTitle),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Model status bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ModelStatus(
                state: widget.llmController.modelState,
                progress: widget.llmController.loadProgress,
                modelName: widget.llmController.modelName,
                errorMessage: widget.llmController.errorMessage,
                onLoadModel: _handleLoadModel,
                semanticsId: 'view.llmChat.modelStatus',
              ),
            ),
            // Chat messages
            Expanded(
              child: widget.llmController.messages.isEmpty
                  ? Center(
                      child: Text(
                        widget.llmController.isReady
                            ? localizations.llmStartChatting
                            : localizations.llmLoadModelFirst,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ChatMessageList(
                      messages: widget.llmController.messages,
                      scrollController: _scrollController,
                      isTyping: widget.llmController.isGenerating,
                      semanticsId: 'view.llmChat.messages',
                    ),
            ),
            // Input area
            ChatInput(
              controller: _textController,
              onSubmit: _handleSubmit,
              enabled: widget.llmController.isReady &&
                  !widget.llmController.isGenerating,
              hintText: localizations.llmInputHint,
              semanticsId: 'view.llmChat.input',
            ),
          ],
        ),
      ),
    );
  }
}
