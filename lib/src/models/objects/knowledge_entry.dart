import 'dart:convert';

/// A knowledge base entry containing information that can be used
/// to provide context to the LLM.
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the entry.
  final String id;

  /// Title or short description of the entry.
  final String title;

  /// The main content/knowledge text.
  final String content;

  /// Tags for categorization and filtering.
  final List<String> tags;

  /// Optional category for grouping entries.
  final String? category;

  /// When the entry was created.
  final DateTime createdAt;

  /// When the entry was last updated.
  final DateTime updatedAt;

  /// Creates a new entry with auto-generated id and timestamps.
  factory KnowledgeEntry.create({
    required String title,
    required String content,
    List<String> tags = const [],
    String? category,
  }) {
    final now = DateTime.now();
    return KnowledgeEntry(
      id: _generateId(),
      title: title,
      content: content,
      tags: tags,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates an entry from a database row map.
  factory KnowledgeEntry.fromMap(Map<String, dynamic> map) {
    return KnowledgeEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: _decodeTags(map['tags'] as String?),
      category: map['category'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Converts the entry to a database row map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': jsonEncode(tags),
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a copy with updated fields and new updatedAt timestamp.
  KnowledgeEntry copyWith({
    String? title,
    String? content,
    List<String>? tags,
    String? category,
  }) {
    return KnowledgeEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Human-readable size of the content.
  String get contentSizeString {
    final bytes = content.length;
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes bytes';
  }

  /// Preview of the content (first 100 characters).
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  static List<String> _decodeTags(String? tagsJson) {
    if (tagsJson == null || tagsJson.isEmpty) return [];
    try {
      final decoded = jsonDecode(tagsJson);
      if (decoded is List) {
        return decoded.cast<String>();
      }
    } catch (_) {}
    return [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'KnowledgeEntry(id: $id, title: $title)';
}
