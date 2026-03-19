import '../../components/organisms/chat_message_list.dart';

/// A saved conversation containing a list of chat messages.
class Conversation {
  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new conversation with a generated ID.
  factory Conversation.create({String title = 'New Conversation'}) {
    final now = DateTime.now();
    return Conversation(
      id: '${now.millisecondsSinceEpoch}_${now.microsecond}',
      title: title,
      messages: <ChatMessage>[],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['messages'] as List?)
            ?.map((m) => ChatMessage(
                  content: m['content'] as String,
                  isUser: m['isUser'] as bool,
                  id: m['id'] as String?,
                ))
            .toList() ??
        <ChatMessage>[];

    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: messagesList,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages
            .map((m) => {
                  'content': m.content,
                  'isUser': m.isUser,
                  'id': m.id,
                })
            .toList(),
        'createdAt': createdAt.microsecondsSinceEpoch,
        'updatedAt': updatedAt.microsecondsSinceEpoch,
      };
}
