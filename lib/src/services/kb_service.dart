import '../clients/local_database_client.dart';
import '../models/objects/knowledge_entry.dart';

/// Result of a knowledge base search, including relevance score.
class KbSearchResult {
  const KbSearchResult({
    required this.entry,
    required this.relevanceScore,
  });

  final KnowledgeEntry entry;
  final double relevanceScore;
}

/// A service that provides knowledge base functionality.
///
/// This service manages knowledge entries that can be used to provide
/// context to the LLM for more informed responses.
class KbService {
  KbService(this._client);

  final LocalDatabaseClient _client;

  static const String _tableName = 'knowledge_entries';
  static const String _ftsTableName = 'knowledge_entries_fts';

  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initialize the service.
  Future<void> init() async {
    await _client.count(_tableName);
    _isInitialized = true;
  }

  // ============ CRUD Operations ============

  /// Adds a new knowledge entry.
  ///
  /// Returns the created entry with generated ID and timestamps.
  Future<KnowledgeEntry> addEntry({
    required String title,
    required String content,
    List<String> tags = const [],
    String? category,
  }) async {
    final entry = KnowledgeEntry.create(
      title: title,
      content: content,
      tags: tags,
      category: category,
    );

    await _client.insert(_tableName, entry.toMap());
    return entry;
  }

  /// Updates an existing knowledge entry.
  ///
  /// Returns the updated entry, or null if not found.
  Future<KnowledgeEntry?> updateEntry(
    String id, {
    String? title,
    String? content,
    List<String>? tags,
    String? category,
  }) async {
    final existing = await getEntry(id);
    if (existing == null) return null;

    final updated = existing.copyWith(
      title: title,
      content: content,
      tags: tags,
      category: category,
    );

    await _client.update(
      _tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    return updated;
  }

  /// Deletes a knowledge entry by ID.
  ///
  /// Returns true if the entry was deleted.
  Future<bool> deleteEntry(String id) async {
    final count = await _client.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// Gets a single knowledge entry by ID.
  Future<KnowledgeEntry?> getEntry(String id) async {
    final results = await _client.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return KnowledgeEntry.fromMap(results.first);
  }

  /// Gets all knowledge entries.
  ///
  /// [category] optional filter by category.
  /// [limit] maximum number of entries to return.
  /// [offset] number of entries to skip.
  /// [orderBy] column to order by (default: updated_at DESC).
  Future<List<KnowledgeEntry>> getEntries({
    String? category,
    int? limit,
    int? offset,
    String orderBy = 'updated_at DESC',
  }) async {
    final results = await _client.query(
      _tableName,
      where: category != null ? 'category = ?' : null,
      whereArgs: category != null ? [category] : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return results.map((map) => KnowledgeEntry.fromMap(map)).toList();
  }

  /// Gets all unique categories.
  Future<List<String>> getCategories() async {
    final results = await _client.rawQuery('''
      SELECT DISTINCT category FROM $_tableName
      WHERE category IS NOT NULL
      ORDER BY category
    ''');

    return results
        .map((row) => row['category'] as String?)
        .whereType<String>()
        .toList();
  }

  /// Gets the total count of entries.
  Future<int> getEntryCount({String? category}) async {
    return await _client.count(
      _tableName,
      where: category != null ? 'category = ?' : null,
      whereArgs: category != null ? [category] : null,
    );
  }

  // ============ Search Operations ============

  /// Searches knowledge entries using full-text search.
  ///
  /// [query] the search query (supports prefix matching).
  /// [limit] maximum number of results.
  /// [offset] number of results to skip.
  ///
  /// Returns entries sorted by relevance.
  Future<List<KbSearchResult>> search(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final ftsResults = await _client.ftsSearch(
      _ftsTableName,
      query,
      limit: limit,
      offset: offset,
    );

    if (ftsResults.isEmpty) {
      return [];
    }

    final rowIds = ftsResults.map((r) => r['rowid']).toList();
    final placeholders = List.filled(rowIds.length, '?').join(',');

    final entries = await _client.rawQuery('''
      SELECT * FROM $_tableName
      WHERE rowid IN ($placeholders)
    ''', rowIds);

    final results = <KbSearchResult>[];
    for (var i = 0; i < ftsResults.length && i < entries.length; i++) {
      final rank = ftsResults[i]['rank'] as double? ?? 0.0;
      final entry = KnowledgeEntry.fromMap(entries[i]);
      results.add(KbSearchResult(
        entry: entry,
        relevanceScore: -rank,
      ));
    }

    return results;
  }

  /// Finds entries by tag.
  Future<List<KnowledgeEntry>> findByTag(String tag) async {
    final results = await _client.query(
      _tableName,
      where: 'tags LIKE ?',
      whereArgs: ['%"$tag"%'],
      orderBy: 'updated_at DESC',
    );

    return results.map((map) => KnowledgeEntry.fromMap(map)).toList();
  }

  // ============ LLM Context Integration ============

  /// Retrieves relevant knowledge entries for a given user query.
  ///
  /// This method is designed to be called before sending a message to the LLM
  /// to provide relevant context.
  ///
  /// [userQuery] the user's message/question.
  /// [maxEntries] maximum number of entries to include (default 3).
  /// [maxTokens] approximate maximum tokens for context (default 1000).
  ///
  /// Returns a formatted context string to inject into the system prompt.
  Future<String?> getContextForQuery(
    String userQuery, {
    int maxEntries = 3,
    int maxTokens = 1000,
  }) async {
    final searchResults = await search(userQuery, limit: maxEntries);

    if (searchResults.isEmpty) {
      return null;
    }

    final buffer = StringBuffer();
    buffer.writeln('Relevant knowledge base information:');
    buffer.writeln();

    int approximateTokens = 0;
    const avgCharsPerToken = 4;

    for (final result in searchResults) {
      final entry = result.entry;
      final entryText = '## ${entry.title}\n${entry.content}\n';
      final entryTokens = entryText.length ~/ avgCharsPerToken;

      if (approximateTokens + entryTokens > maxTokens) {
        break;
      }

      buffer.writeln('## ${entry.title}');
      buffer.writeln(entry.content);
      buffer.writeln();
      approximateTokens += entryTokens;
    }

    return buffer.toString().trim();
  }

  /// Builds a system prompt with injected knowledge base context.
  ///
  /// [baseSystemPrompt] the original system prompt.
  /// [userQuery] the user's message for context retrieval.
  /// [maxContextTokens] maximum tokens for KB context.
  ///
  /// Returns the enhanced system prompt with context.
  Future<String> buildSystemPromptWithContext(
    String baseSystemPrompt,
    String userQuery, {
    int maxContextTokens = 1000,
  }) async {
    final context = await getContextForQuery(
      userQuery,
      maxTokens: maxContextTokens,
    );

    if (context == null) {
      return baseSystemPrompt;
    }

    return '''
$baseSystemPrompt

---
$context
---

Use the above knowledge base information to help answer the user's question when relevant.
''';
  }

  // ============ Bulk Operations ============

  /// Imports multiple entries at once.
  ///
  /// Returns the number of entries imported.
  Future<int> importEntries(List<KnowledgeEntry> entries) async {
    if (entries.isEmpty) return 0;

    return await _client.transaction((txn) async {
      int count = 0;
      for (final entry in entries) {
        await txn.insert(_tableName, entry.toMap());
        count++;
      }
      return count;
    });
  }

  /// Deletes all entries.
  Future<void> clearAll() async {
    await _client.delete(_tableName);
  }

  /// Deletes all entries in a category.
  Future<int> clearCategory(String category) async {
    return await _client.delete(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
  }
}
