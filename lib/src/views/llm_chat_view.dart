import 'package:flutter/material.dart';

import '../clients/local_filesystem_client.dart';
import '../clients/download_llm_client.dart';
import '../components/molecules/chat_input.dart';
import '../components/molecules/model_status.dart';
import '../components/organisms/chat_message_list.dart';
import '../components/templates/bottom_navigation.dart';
import '../controllers/llm_controller.dart';
import '../localization/app_localizations.dart';
import '../models/interfaces/control_interface.dart';
import 'llm_models_view.dart';

/// LLM Chat view with local model inference.
class LlmChatView extends StatefulWidget {
  const LlmChatView({
    super.key,
    required this.controls,
    required this.llmController,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  static const routeName = '/llm-chat';

  final ControlInterface controls;
  final LlmController llmController;
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      identifier: 'view.llmChat',
      label: 'Page',
      child: Scaffold(
        key: const ValueKey('view.llmChat'),
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
                  case 'clear':
                    widget.llmController.clearMessages();
                    break;
                  case 'unload':
                    widget.llmController.unloadModel();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Text(localizations.llmClearChat),
                ),
                if (widget.llmController.isReady)
                  PopupMenuItem(
                    value: 'unload',
                    child: Text(localizations.llmUnloadModel),
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
        bottomNavigationBar: BottomNavigation(
          navigationController: widget.controls.navigation,
          semanticsId: 'view.llmChat.bottomNav',
        ),
      ),
    );
  }
}
