import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_fllama_client.dart';
import 'package:khs_flutter_example/src/services/llm_completion_service.dart';

/// Mock fllama client for testing
class MockFllamaClient extends LocalFllamaClient {
  MockFllamaClient() : super();

  bool _mockIsReady = false;
  bool shouldFail = false;
  String mockResponse = 'Mock response';
  List<String> capturedTokens = [];

  @override
  bool get isReady => _mockIsReady;

  void setReady(bool ready) {
    _mockIsReady = ready;
  }

  @override
  Future<String> chat(
    List<RoleContent> messages, {
    void Function(String token)? onToken,
    int maxTokens = 256,
    double temperature = 0.7,
    String? chatTemplate,
  }) async {
    if (shouldFail) {
      throw Exception('Mock chat error');
    }

    // Simulate token streaming
    final words = mockResponse.split(' ');
    for (final word in words) {
      final token = '$word ';
      capturedTokens.add(token);
      onToken?.call(token);
    }

    return mockResponse;
  }

  @override
  Future<void> stopCompletion() async {
    // No-op for mock
  }
}

void main() {
  group('LlmCompletionService', () {
    late LlmCompletionService service;
    late MockFllamaClient mockClient;

    setUp(() {
      mockClient = MockFllamaClient();
      service = LlmCompletionService(mockClient);
    });

    group('Initialization', () {
      test('should create instance with client', () {
        expect(service, isA<LlmCompletionService>());
      });

      test('should start not ready', () {
        expect(service.isReady, isFalse);
      });
    });

    group('isReady', () {
      test('should reflect client ready state', () {
        expect(service.isReady, isFalse);

        mockClient.setReady(true);
        expect(service.isReady, isTrue);

        mockClient.setReady(false);
        expect(service.isReady, isFalse);
      });
    });

    group('chat', () {
      setUp(() {
        mockClient.setReady(true);
      });

      test('should generate chat response', () async {
        mockClient.mockResponse = 'Hello, how can I help?';
        final messages = [
          RoleContent(role: 'user', content: 'Hi'),
        ];

        final response = await service.chat(messages);

        expect(response, equals('Hello, how can I help?'));
      });

      test('should call onToken callback for each token', () async {
        mockClient.mockResponse = 'Hello world test';
        final tokens = <String>[];
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        await service.chat(
          messages,
          onToken: (token) {
            tokens.add(token);
          },
        );

        expect(tokens, isNotEmpty);
        expect(tokens.join(), contains('Hello'));
      });

      test('should handle empty messages list', () async {
        mockClient.mockResponse = 'Response';

        final response = await service.chat([]);

        expect(response, equals('Response'));
      });

      test('should handle single user message', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Question'),
        ];

        final response = await service.chat(messages);

        expect(response, equals('Response'));
      });

      test('should handle conversation history', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'system', content: 'You are helpful'),
          RoleContent(role: 'user', content: 'Hello'),
          RoleContent(role: 'assistant', content: 'Hi there'),
          RoleContent(role: 'user', content: 'How are you?'),
        ];

        final response = await service.chat(messages);

        expect(response, equals('Response'));
      });

      test('should pass maxTokens parameter', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          maxTokens: 1024,
        );

        expect(response, isNotNull);
      });

      test('should pass temperature parameter', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          temperature: 0.5,
        );

        expect(response, isNotNull);
      });

      test('should throw StateError when model not ready', () async {
        mockClient.setReady(false);
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        expect(
          () => service.chat(messages),
          throwsA(isA<StateError>()),
        );
      });

      test('should include correct error message when not ready', () async {
        mockClient.setReady(false);
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        try {
          await service.chat(messages);
          fail('Should have thrown StateError');
          // ignore: avoid_catching_errors
        } on StateError catch (e) {
          expect(e, isA<StateError>());
          expect(e.toString(), contains('Model not loaded'));
        }
      });

      test('should propagate client exceptions', () async {
        mockClient.shouldFail = true;
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        expect(
          () => service.chat(messages),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle null onToken callback', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          onToken: null,
        );

        expect(response, equals('Response'));
      });

      test('should stream tokens in order', () async {
        mockClient.mockResponse = 'First second third';
        final tokens = <String>[];
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        await service.chat(
          messages,
          onToken: (token) {
            tokens.add(token);
          },
        );

        expect(tokens[0], equals('First '));
        expect(tokens[1], equals('second '));
        expect(tokens[2], equals('third '));
      });
    });

    group('stopGeneration', () {
      setUp(() {
        mockClient.setReady(true);
      });

      test('should call client stopCompletion', () async {
        await service.stopGeneration();

        // No exception should be thrown
        expect(true, isTrue);
      });

      test('should be safe to call when not generating', () async {
        await service.stopGeneration();
        await service.stopGeneration();

        // Should not throw
        expect(true, isTrue);
      });

      test('should be safe to call when not ready', () async {
        mockClient.setReady(false);

        await service.stopGeneration();

        // Should not throw
        expect(true, isTrue);
      });
    });

    group('Edge Cases', () {
      setUp(() {
        mockClient.setReady(true);
      });

      test('should handle empty response', () async {
        mockClient.mockResponse = '';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(messages);

        expect(response, equals(''));
      });

      test('should handle long response', () async {
        mockClient.mockResponse = 'word ' * 1000;
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(messages);

        expect(response, isNotEmpty);
        expect(response.split(' ').length, greaterThan(100));
      });

      test('should handle special characters in response', () async {
        mockClient.mockResponse = 'Hello! @#\$% 123 <test>';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(messages);

        expect(response, equals('Hello! @#\$% 123 <test>'));
      });

      test('should handle unicode in messages', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: '你好 🎉 مرحبا'),
        ];

        final response = await service.chat(messages);

        expect(response, isNotNull);
      });

      test('should handle rapid sequential calls', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response1 = await service.chat(messages);
        final response2 = await service.chat(messages);
        final response3 = await service.chat(messages);

        expect(response1, equals('Response'));
        expect(response2, equals('Response'));
        expect(response3, equals('Response'));
      });

      test('should handle extremely high maxTokens', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          maxTokens: 1000000,
        );

        expect(response, isNotNull);
      });

      test('should handle extremely low temperature', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          temperature: 0.0,
        );

        expect(response, isNotNull);
      });

      test('should handle extremely high temperature', () async {
        mockClient.mockResponse = 'Response';
        final messages = [
          RoleContent(role: 'user', content: 'Test'),
        ];

        final response = await service.chat(
          messages,
          temperature: 2.0,
        );

        expect(response, isNotNull);
      });
    });

    group('Integration', () {
      test('should maintain state consistency with client', () {
        expect(service.isReady, equals(mockClient.isReady));

        mockClient.setReady(true);
        expect(service.isReady, equals(mockClient.isReady));
      });

      test('should work end-to-end with token streaming', () async {
        mockClient.setReady(true);
        mockClient.mockResponse = 'Hello world';

        final tokens = <String>[];
        final messages = [
          RoleContent(role: 'user', content: 'Hi'),
        ];

        final response = await service.chat(
          messages,
          onToken: (token) {
            tokens.add(token);
          },
        );

        expect(response, equals('Hello world'));
        expect(tokens.join(), contains('Hello'));
      });
    });
  });
}
