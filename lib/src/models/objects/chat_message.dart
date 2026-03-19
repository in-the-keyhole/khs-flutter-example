/// A chat message data class.
class ChatMessage {
  const ChatMessage({
    required this.content,
    required this.isUser,
    this.id,
  });

  final String content;
  final bool isUser;
  final String? id;
}
