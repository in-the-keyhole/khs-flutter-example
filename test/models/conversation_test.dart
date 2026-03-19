import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/organisms/chat_message_list.dart';
import 'package:khs_flutter_example/src/models/objects/conversation.dart';

void main() {
  group('Conversation', () {
    test('should create instance with required fields', () {
      final now = DateTime.now();
      final conversation = Conversation(
        id: 'test-id',
        title: 'Test Conversation',
        messages: [],
        createdAt: now,
        updatedAt: now,
      );

      expect(conversation.id, equals('test-id'));
      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.messages, isEmpty);
      expect(conversation.createdAt, equals(now));
      expect(conversation.updatedAt, equals(now));
    });

    test('should allow messages to be added', () {
      final conversation = Conversation.create();
      const message = ChatMessage(content: 'Hello', isUser: true);

      conversation.messages.add(message);

      expect(conversation.messages.length, equals(1));
      expect(conversation.messages.first.content, equals('Hello'));
    });

    test('should allow title to be updated', () {
      final conversation = Conversation.create(title: 'Original');

      conversation.title = 'Updated';

      expect(conversation.title, equals('Updated'));
    });

    test('should allow updatedAt to be updated', () {
      final conversation = Conversation.create();
      final newTime = DateTime.now().add(const Duration(hours: 1));

      conversation.updatedAt = newTime;

      expect(conversation.updatedAt, equals(newTime));
    });

    group('create factory', () {
      test('should create conversation with default title', () {
        final conversation = Conversation.create();

        expect(conversation.title, equals('New Conversation'));
        expect(conversation.messages, isEmpty);
      });

      test('should create conversation with custom title', () {
        final conversation = Conversation.create(title: 'My Chat');

        expect(conversation.title, equals('My Chat'));
      });

      test('should generate unique ID', () {
        final conv1 = Conversation.create();
        final conv2 = Conversation.create();

        expect(conv1.id, isNotEmpty);
        expect(conv2.id, isNotEmpty);
        expect(conv1.id, isNot(equals(conv2.id)));
      });

      test('should set createdAt and updatedAt to same time', () {
        final conversation = Conversation.create();

        expect(
          conversation.createdAt.microsecondsSinceEpoch,
          equals(conversation.updatedAt.microsecondsSinceEpoch),
        );
      });

      test('should set timestamps to current time', () {
        final before = DateTime.now();
        final conversation = Conversation.create();
        final after = DateTime.now();

        expect(conversation.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(conversation.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('toJson', () {
      test('should serialize to JSON', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final conversation = Conversation(
          id: 'test-id',
          title: 'Test',
          messages: [
            const ChatMessage(content: 'Hello', isUser: true, id: 'msg1'),
            const ChatMessage(content: 'Hi', isUser: false, id: 'msg2'),
          ],
          createdAt: now,
          updatedAt: now,
        );

        final json = conversation.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['title'], equals('Test'));
        expect(json['messages'], isA<List<dynamic>>());
        expect(json['messages'].length, equals(2));
        expect(json['createdAt'], equals(now.microsecondsSinceEpoch));
        expect(json['updatedAt'], equals(now.microsecondsSinceEpoch));
      });

      test('should serialize messages correctly', () {
        final conversation = Conversation.create();
        conversation.messages.add(
          const ChatMessage(content: 'Test message', isUser: true, id: 'msg1'),
        );

        final json = conversation.toJson();
        final messages = json['messages'] as List<dynamic>;

        expect(messages[0]['content'], equals('Test message'));
        expect(messages[0]['isUser'], equals(true));
        expect(messages[0]['id'], equals('msg1'));
      });

      test('should handle empty messages', () {
        final conversation = Conversation.create();

        final json = conversation.toJson();

        expect(json['messages'], isEmpty);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final json = {
          'id': 'test-id',
          'title': 'Test',
          'messages': [
            {'content': 'Hello', 'isUser': true, 'id': 'msg1'},
            {'content': 'Hi', 'isUser': false, 'id': 'msg2'},
          ],
          'createdAt': now.microsecondsSinceEpoch,
          'updatedAt': now.microsecondsSinceEpoch,
        };

        final conversation = Conversation.fromJson(json);

        expect(conversation.id, equals('test-id'));
        expect(conversation.title, equals('Test'));
        expect(conversation.messages.length, equals(2));
        expect(conversation.createdAt, equals(now));
        expect(conversation.updatedAt, equals(now));
      });

      test('should deserialize messages correctly', () {
        final json = {
          'id': 'test',
          'title': 'Test',
          'messages': [
            {'content': 'Hello', 'isUser': true, 'id': 'msg1'},
          ],
          'createdAt': DateTime.now().microsecondsSinceEpoch,
          'updatedAt': DateTime.now().microsecondsSinceEpoch,
        };

        final conversation = Conversation.fromJson(json);

        expect(conversation.messages[0].content, equals('Hello'));
        expect(conversation.messages[0].isUser, isTrue);
        expect(conversation.messages[0].id, equals('msg1'));
      });

      test('should handle null messages list', () {
        final json = {
          'id': 'test',
          'title': 'Test',
          'messages': null,
          'createdAt': DateTime.now().microsecondsSinceEpoch,
          'updatedAt': DateTime.now().microsecondsSinceEpoch,
        };

        final conversation = Conversation.fromJson(json);

        expect(conversation.messages, isEmpty);
      });

      test('should handle missing messages key', () {
        final json = {
          'id': 'test',
          'title': 'Test',
          'createdAt': DateTime.now().microsecondsSinceEpoch,
          'updatedAt': DateTime.now().microsecondsSinceEpoch,
        };

        final conversation = Conversation.fromJson(json);

        expect(conversation.messages, isEmpty);
      });
    });

    group('Round-trip serialization', () {
      test('should preserve data through serialization', () {
        final original = Conversation.create(title: 'Test');
        original.messages.add(
          const ChatMessage(content: 'Message 1', isUser: true, id: 'msg1'),
        );
        original.messages.add(
          const ChatMessage(content: 'Message 2', isUser: false, id: 'msg2'),
        );

        final json = original.toJson();
        final restored = Conversation.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.messages.length, equals(original.messages.length));
        expect(restored.createdAt, equals(original.createdAt));
        expect(restored.updatedAt, equals(original.updatedAt));
      });

      test('should preserve message content and order', () {
        final original = Conversation.create();
        original.messages.add(
          const ChatMessage(content: 'First', isUser: true, id: 'msg1'),
        );
        original.messages.add(
          const ChatMessage(content: 'Second', isUser: false, id: 'msg2'),
        );

        final restored = Conversation.fromJson(original.toJson());

        expect(restored.messages[0].content, equals('First'));
        expect(restored.messages[0].isUser, isTrue);
        expect(restored.messages[1].content, equals('Second'));
        expect(restored.messages[1].isUser, isFalse);
      });
    });
  });
}
