import 'package:flutter/material.dart';

/// A chat input molecule combining a text field and send button.
///
/// Used for entering and submitting chat messages.
class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.semanticsId,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String hintText;
  final bool enabled;
  final String? semanticsId;

  void _handleSubmit() {
    if (controller.text.trim().isNotEmpty) {
      onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      identifier: semanticsId,
      label: 'Chat input',
      child: Container(
        key: semanticsId != null ? ValueKey(semanticsId) : null,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: semanticsId != null
                      ? ValueKey('$semanticsId.textField')
                      : null,
                  controller: controller,
                  enabled: enabled,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: semanticsId != null
                    ? ValueKey('$semanticsId.sendButton')
                    : null,
                onPressed: enabled ? _handleSubmit : null,
                icon: const Icon(Icons.send),
                tooltip: 'Send message',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
