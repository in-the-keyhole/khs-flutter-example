import 'dart:convert';
import 'dart:io';

import '../clients/local_filesystem_client.dart';
import '../models/objects/conversation.dart';

/// Service that persists conversations as JSON using the filesystem client.
class ConversationStorageService {
  ConversationStorageService(this._filesystemClient, {String? directoryPath})
      : _directoryPath = directoryPath;

  final LocalFilesystemClient _filesystemClient;
  final String? _directoryPath;
  static const String _fileName = 'conversations.json';

  Future<String> _getFilePath() async {
    final dir =
        _directoryPath ?? (await _filesystemClient.getSupportDirectory()).path;
    return '$dir/$_fileName';
  }

  /// Loads all saved conversations from disk.
  /// Returns an empty list if the file doesn't exist or is invalid.
  Future<List<Conversation>> loadAll() async {
    try {
      final path = await _getFilePath();
      if (!File(path).existsSync()) return [];

      final contents = File(path).readAsStringSync();
      if (contents.isEmpty) return [];

      final list = jsonDecode(contents) as List;
      return list
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Exception catch (_) {
      return [];
    }
  }

  /// Saves all conversations to disk.
  Future<void> saveAll(List<Conversation> conversations) async {
    final path = await _getFilePath();
    final json = conversations.map((c) => c.toJson()).toList();
    await File(path).writeAsString(jsonEncode(json));
  }

  /// Deletes the conversations file.
  Future<void> deleteFile() async {
    final path = await _getFilePath();
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
