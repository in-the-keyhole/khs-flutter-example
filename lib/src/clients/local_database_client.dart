import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// A client that handles local SQLite database operations.
///
/// This client provides a clean abstraction over the sqflite package,
/// with support for migrations, transactions, and FTS5 full-text search.
class LocalDatabaseClient {
  LocalDatabaseClient({Database? db}) : _db = db;

  Database? _db;
  Future<Database>? _dbLoading;
  bool _isInitializing = false;

  static const String _databaseName = 'knowledge_base.db';
  static const int _databaseVersion = 1;

  /// Whether the database is connected and ready.
  bool get isConnected => _db != null;

  /// Whether the database is currently initializing.
  bool get isInitializing => _isInitializing;

  /// Ensures the database is initialized, using lazy loading.
  Future<Database> _ensureDatabase() {
    final existing = _db;
    if (existing != null) {
      return Future.value(existing);
    }

    final loading = _dbLoading;
    if (loading != null) {
      return loading;
    }

    final future = _initDatabase().then((db) {
      _db = db;
      _dbLoading = null;
      return db;
    });
    _dbLoading = future;
    return future;
  }

  Future<Database> _initDatabase() async {
    _isInitializing = true;
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _runMigrations(db, 0, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _runMigrations(db, oldVersion, newVersion);
  }

  Future<void> _runMigrations(Database db, int from, int to) async {
    for (var version = from + 1; version <= to; version++) {
      await _applyMigration(db, version);
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _migrationV1(db);
        break;
    }
  }

  /// Migration v1: Initial schema with knowledge_entries and FTS5
  Future<void> _migrationV1(Database db) async {
    // Create migrations tracking table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS _migrations (
        version INTEGER PRIMARY KEY,
        applied_at INTEGER NOT NULL
      )
    ''');

    // Create main entries table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS knowledge_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_knowledge_entries_category
      ON knowledge_entries(category)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_knowledge_entries_updated
      ON knowledge_entries(updated_at DESC)
    ''');

    // Create FTS5 virtual table
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_entries_fts
      USING fts5(title, content, tags, content='knowledge_entries', content_rowid='rowid')
    ''');

    // Create triggers for FTS synchronization
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS knowledge_entries_ai AFTER INSERT ON knowledge_entries BEGIN
        INSERT INTO knowledge_entries_fts(rowid, title, content, tags)
        VALUES (NEW.rowid, NEW.title, NEW.content, NEW.tags);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS knowledge_entries_ad AFTER DELETE ON knowledge_entries BEGIN
        INSERT INTO knowledge_entries_fts(knowledge_entries_fts, rowid, title, content, tags)
        VALUES('delete', OLD.rowid, OLD.title, OLD.content, OLD.tags);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS knowledge_entries_au AFTER UPDATE ON knowledge_entries BEGIN
        INSERT INTO knowledge_entries_fts(knowledge_entries_fts, rowid, title, content, tags)
        VALUES('delete', OLD.rowid, OLD.title, OLD.content, OLD.tags);
        INSERT INTO knowledge_entries_fts(rowid, title, content, tags)
        VALUES (NEW.rowid, NEW.title, NEW.content, NEW.tags);
      END
    ''');

    // Record migration
    await db.insert('_migrations', {
      'version': 1,
      'applied_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Factory method to create a pre-initialized LocalDatabaseClient.
  static Future<LocalDatabaseClient> create() async {
    final client = LocalDatabaseClient();
    await client._ensureDatabase();
    return client;
  }

  // ============ Generic CRUD Operations ============

  /// Inserts a row into the specified table.
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await _ensureDatabase();
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates rows in the specified table.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await _ensureDatabase();
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Deletes rows from the specified table.
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await _ensureDatabase();
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Queries rows from the specified table.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _ensureDatabase();
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Executes a raw SQL query with optional arguments.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await _ensureDatabase();
    return await db.rawQuery(sql, arguments);
  }

  /// Executes a raw SQL statement (INSERT, UPDATE, DELETE).
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await _ensureDatabase();
    await db.execute(sql, arguments);
  }

  // ============ Transaction Support ============

  /// Executes a batch of operations in a transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await _ensureDatabase();
    return await db.transaction(action);
  }

  /// Creates a batch for efficient bulk operations.
  Future<Batch> batch() async {
    final db = await _ensureDatabase();
    return db.batch();
  }

  // ============ FTS5 Full-Text Search ============

  /// Performs a full-text search on the FTS5 table.
  ///
  /// [ftsTable] the FTS5 virtual table name.
  /// [query] the search query (supports FTS5 syntax).
  /// [limit] maximum number of results.
  /// [offset] number of results to skip.
  ///
  /// Returns a list of matching row IDs with their relevance scores.
  Future<List<Map<String, dynamic>>> ftsSearch(
    String ftsTable,
    String query, {
    int? limit,
    int? offset,
  }) async {
    final db = await _ensureDatabase();

    final sanitizedQuery = _sanitizeFtsQuery(query);
    if (sanitizedQuery.isEmpty) {
      return [];
    }

    var sql = '''
      SELECT rowid, rank
      FROM $ftsTable
      WHERE $ftsTable MATCH ?
      ORDER BY rank
    ''';

    if (limit != null) {
      sql += ' LIMIT $limit';
      if (offset != null) {
        sql += ' OFFSET $offset';
      }
    }

    return await db.rawQuery(sql, [sanitizedQuery]);
  }

  /// Sanitizes a query string for safe FTS5 usage.
  String _sanitizeFtsQuery(String query) {
    return query
        .replaceAll('"', '""')
        .split(' ')
        .where((term) => term.isNotEmpty)
        .map((term) => '"$term"*')
        .join(' ');
  }

  // ============ Utility Methods ============

  /// Gets the count of rows in a table.
  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await _ensureDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? " WHERE $where" : ""}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Checks if a row exists with the given condition.
  Future<bool> exists(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final result = await query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Gets the database file path.
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
      _dbLoading = null;
    }
  }

  /// Deletes the database file completely.
  Future<void> deleteDatabase() async {
    await close();
    final path = await getDatabasePath();
    await databaseFactory.deleteDatabase(path);
  }
}
