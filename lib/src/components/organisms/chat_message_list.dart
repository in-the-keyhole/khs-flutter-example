import 'package:flutter/material.dart';

import '../../models/objects/chat_message.dart';
import '../atoms/chat_bubble.dart';
import '../atoms/typing_indicator.dart';

export '../../models/objects/chat_message.dart';

/// A scrollable list of chat messages organism.
///
/// Displays a list of chat bubbles with optional typing indicator.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isTyping = false,
    this.semanticsId,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isTyping;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      label: 'Chat messages',
      child: ListView.builder(
        key: semanticsId != null ? ValueKey<String>(semanticsId!) : null,
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: messages.length + (isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messages.length && isTyping) {
            return TypingIndicator(
              semanticsId: semanticsId != null
                  ? '$semanticsId.typing'
                  : null,
            );
          }

          final message = messages[index];
          return ChatBubble(
            message: message.content,
            isUser: message.isUser,
            semanticsId: semanticsId != null
                ? '$semanticsId.message.$index'
                : null,
          );
        },
      ),
    );
  }
}
