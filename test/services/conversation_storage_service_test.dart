import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_filesystem_client.dart';
import 'package:khs_flutter_example/src/components/organisms/chat_message_list.dart';
import 'package:khs_flutter_example/src/models/objects/conversation.dart';
import 'package:khs_flutter_example/src/services/conversation_storage_service.dart';

/// Minimal FilePicker mock to allow LocalFilesystemClient construction in tests.
class _MockFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      null;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async =>
      null;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async =>
      null;

  @override
  Future<bool?> clearTemporaryFiles() async => true;
}

void main() {
  group('ConversationStorageService', () {
    late Directory tempDir;
    late ConversationStorageService service;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('conversation_test_');
      service = ConversationStorageService(
        LocalFilesystemClient(filePicker: _MockFilePicker()),
        directoryPath: tempDir.path,
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Conversation createTestConversation({
      String id = 'test_id',
      String title = 'Test Conversation',
      List<ChatMessage>? messages,
    }) {
      return Conversation(
        id: id,
        title: title,
        messages: messages ?? [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    group('loadAll', () {
      test('should return empty list when file does not exist', () async {
        final result = await service.loadAll();
        expect(result, isEmpty);
      });

      test('should return empty list when file is empty', () async {
        final file = File('${tempDir.path}/conversations.json');
        await file.writeAsString('');

        final result = await service.loadAll();
        expect(result, isEmpty);
      });

      test('should return empty list for invalid JSON', () async {
        final file = File('${tempDir.path}/conversations.json');
        await file.writeAsString('not valid json');

        final result = await service.loadAll();
        expect(result, isEmpty);
      });

      test('should load conversations from valid JSON', () async {
        final conversations = [
          createTestConversation(id: '1', title: 'First'),
          createTestConversation(id: '2', title: 'Second'),
        ];

        final file = File('${tempDir.path}/conversations.json');
        await file.writeAsString(
            jsonEncode(conversations.map((c) => c.toJson()).toList()));

        final result = await service.loadAll();
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].title, equals('First'));
        expect(result[1].id, equals('2'));
        expect(result[1].title, equals('Second'));
      });

      test('should load conversations with messages', () async {
        final conversation = createTestConversation(
          messages: [
            const ChatMessage(content: 'Hello', isUser: true, id: 'msg_1'),
            const ChatMessage(content: 'Hi there!', isUser: false, id: 'msg_2'),
          ],
        );

        final file = File('${tempDir.path}/conversations.json');
        await file.writeAsString(jsonEncode([conversation.toJson()]));

        final result = await service.loadAll();
        expect(result.length, equals(1));
        expect(result[0].messages.length, equals(2));
        expect(result[0].messages[0].content, equals('Hello'));
        expect(result[0].messages[0].isUser, isTrue);
        expect(result[0].messages[1].content, equals('Hi there!'));
        expect(result[0].messages[1].isUser, isFalse);
      });
    });

    group('saveAll', () {
      test('should create file and save conversations', () async {
        final conversations = [
          createTestConversation(id: '1', title: 'Saved'),
        ];

        await service.saveAll(conversations);

        final file = File('${tempDir.path}/conversations.json');
        expect(file.existsSync(), isTrue);

        final contents = await file.readAsString();
        final decoded = jsonDecode(contents) as List;
        expect(decoded.length, equals(1));
        expect(decoded[0]['id'], equals('1'));
        expect(decoded[0]['title'], equals('Saved'));
      });

      test('should overwrite existing file', () async {
        await service.saveAll([
          createTestConversation(id: '1', title: 'Original'),
        ]);

        await service.saveAll([
          createTestConversation(id: '2', title: 'Updated'),
        ]);

        final result = await service.loadAll();
        expect(result.length, equals(1));
        expect(result[0].id, equals('2'));
        expect(result[0].title, equals('Updated'));
      });

      test('should save empty list', () async {
        await service.saveAll([]);

        final result = await service.loadAll();
        expect(result, isEmpty);
      });

      test('should preserve messages in saved conversations', () async {
        final conversation = createTestConversation(
          messages: [
            const ChatMessage(content: 'Test message', isUser: true, id: 'm1'),
          ],
        );

        await service.saveAll([conversation]);

        final result = await service.loadAll();
        expect(result[0].messages.length, equals(1));
        expect(result[0].messages[0].content, equals('Test message'));
      });
    });

    group('deleteFile', () {
      test('should delete existing file', () async {
        await service.saveAll([createTestConversation()]);

        final file = File('${tempDir.path}/conversations.json');
        expect(file.existsSync(), isTrue);

        await service.deleteFile();
        expect(file.existsSync(), isFalse);
      });

      test('should not throw when file does not exist', () async {
        await service.deleteFile();
      });

      test('should result in empty loadAll after delete', () async {
        await service.saveAll([createTestConversation()]);
        await service.deleteFile();

        final result = await service.loadAll();
        expect(result, isEmpty);
      });
    });

    group('round-trip', () {
      test('should preserve all fields through save and load', () async {
        final now = DateTime(2025, 6, 15, 10, 30);
        final conversation = Conversation(
          id: 'round_trip_id',
          title: 'Round Trip Test',
          messages: [
            const ChatMessage(content: 'User msg', isUser: true, id: 'u1'),
            const ChatMessage(content: 'Bot response', isUser: false, id: 'b1'),
          ],
          createdAt: now,
          updatedAt: now,
        );

        await service.saveAll([conversation]);
        final result = await service.loadAll();

        expect(result.length, equals(1));
        final loaded = result[0];
        expect(loaded.id, equals('round_trip_id'));
        expect(loaded.title, equals('Round Trip Test'));
        expect(loaded.messages.length, equals(2));
        expect(loaded.createdAt.millisecondsSinceEpoch,
            equals(now.millisecondsSinceEpoch));
        expect(loaded.updatedAt.millisecondsSinceEpoch,
            equals(now.millisecondsSinceEpoch));
      });
    });
  });

  group('Conversation', () {
    group('create', () {
      test('should create with default title', () {
        final conversation = Conversation.create();
        expect(conversation.title, equals('New Conversation'));
        expect(conversation.messages, isEmpty);
        expect(conversation.id, isNotEmpty);
      });

      test('should create with custom title', () {
        final conversation = Conversation.create(title: 'My Chat');
        expect(conversation.title, equals('My Chat'));
      });

      test('should generate unique IDs', () {
        final c1 = Conversation.create();
        final c2 = Conversation.create();
        expect(c1.id, isNot(equals(c2.id)));
      });
    });

    group('toJson / fromJson', () {
      test('should serialize and deserialize correctly', () {
        final original = Conversation(
          id: 'json_test',
          title: 'JSON Test',
          messages: [
            const ChatMessage(content: 'Hello', isUser: true, id: 'h1'),
          ],
          createdAt: DateTime(2025, 3, 1),
          updatedAt: DateTime(2025, 3, 2),
        );

        final json = original.toJson();
        final restored = Conversation.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.messages.length, equals(1));
        expect(restored.messages[0].content, equals('Hello'));
        expect(restored.messages[0].isUser, isTrue);
      });

      test('should handle empty messages list', () {
        final original = Conversation(
          id: 'empty_msgs',
          title: 'Empty',
          messages: [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final json = original.toJson();
        final restored = Conversation.fromJson(json);
        expect(restored.messages, isEmpty);
      });

      test('should handle null messages in JSON', () {
        final json = {
          'id': 'null_msgs',
          'title': 'Null Messages',
          'messages': null,
          'createdAt': DateTime(2025, 1, 1).millisecondsSinceEpoch,
          'updatedAt': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        };

        final conversation = Conversation.fromJson(json);
        expect(conversation.messages, isEmpty);
      });
    });
  });
}
