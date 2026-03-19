import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/components/molecules/model_status.dart';
import 'package:khs_flutter_example/src/controllers/llm_controller.dart';
import 'package:khs_flutter_example/src/models/objects/chat_message.dart';
import 'package:khs_flutter_example/src/services/llm_completion_service.dart';
import 'package:khs_flutter_example/src/services/llm_models_service.dart';

import '../mocks/mock_fllama_client.dart';

void main() {
  group('LlmController', () {
    late LlmController controller;
    late LlmCompletionService completionService;
    late LlmModelsService modelsService;
    late MockFllamaClient mockClient;

    setUp(() {
      mockClient = MockFllamaClient();
      completionService = LlmCompletionService(mockClient);
      modelsService = LlmModelsService(mockClient);
      controller = LlmController(completionService, modelsService);
    });

    group('Initialization', () {
      test('should create instance with service', () {
        expect(controller, isA<LlmController>());
        expect(controller, isA<ChangeNotifier>());
      });

      test('should start with notLoaded state', () {
        expect(controller.modelState, equals(ModelState.notLoaded));
      });

      test('should start with empty messages', () {
        expect(controller.messages, isEmpty);
      });

      test('should start not generating', () {
        expect(controller.isGenerating, isFalse);
      });

      test('should start not ready', () {
        expect(controller.isReady, isFalse);
      });
    });

    group('loadModel', () {
      test('should load model successfully', () async {
        await controller.loadModel('/path/to/model.gguf');

        expect(controller.modelState, equals(ModelState.ready));
        expect(controller.isReady, isTrue);
      });

      test('should update progress during load', () async {
        final progressValues = <double>[];
        controller.addListener(() {
          progressValues.add(controller.loadProgress);
        });

        await controller.loadModel('/path/to/model.gguf');

        expect(progressValues, isNotEmpty);
        expect(progressValues.last, equals(1.0));
      });

      test('should transition through loading state', () async {
        final states = <ModelState>[];
        controller.addListener(() {
          states.add(controller.modelState);
        });

        await controller.loadModel('/path/to/model.gguf');

        expect(states.contains(ModelState.loading), isTrue);
        expect(states.last, equals(ModelState.ready));
      });

      test('should handle load failure', () async {
        mockClient.shouldFailLoad = true;

        await controller.loadModel('/path/to/model.gguf');

        expect(controller.modelState, equals(ModelState.error));
        expect(controller.errorMessage, isNotNull);
      });

      test('should set model name', () async {
        await controller.loadModel('/path/to/model.gguf', modelName: 'Test Model');

        expect(controller.modelName, equals('Test Model'));
      });

      test('should notify listeners', () async {
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        await controller.loadModel('/path/to/model.gguf');

        expect(notified, isTrue);
      });
    });

    group('unloadModel', () {
      test('should unload model', () async {
        await controller.loadModel('/path/to/model.gguf');
        expect(controller.isReady, isTrue);

        await controller.unloadModel();

        expect(controller.modelState, equals(ModelState.notLoaded));
        expect(controller.loadProgress, equals(0.0));
      });

      test('should notify listeners', () async {
        await controller.loadModel('/path/to/model.gguf');

        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        await controller.unloadModel();

        expect(notified, isTrue);
      });
    });

    group('sendMessage', () {
      setUp(() async {
        await controller.loadModel('/path/to/model.gguf');
      });

      test('should add user message', () async {
        await controller.sendMessage('Hello');

        expect(controller.messages.length, equals(2)); // User + Assistant
        expect(controller.messages.first.content, equals('Hello'));
        expect(controller.messages.first.isUser, isTrue);
      });

      test('should add assistant response', () async {
        mockClient.mockResponse = 'Hi there!';

        await controller.sendMessage('Hello');

        expect(controller.messages.length, equals(2));
        expect(controller.messages.last.content, equals('Hi there!'));
        expect(controller.messages.last.isUser, isFalse);
      });

      test('should not send empty message', () async {
        await controller.sendMessage('');
        await controller.sendMessage('   ');

        expect(controller.messages, isEmpty);
      });

      test('should not send when not ready', () async {
        await controller.unloadModel();

        await controller.sendMessage('Hello');

        expect(controller.messages, isEmpty);
      });

      test('should not send while generating', () async {
        mockClient.completeDelayMs = 1000;

        // Start a message
        final future1 = controller.sendMessage('First');

        // Try to send another immediately
        await controller.sendMessage('Second');

        await future1;

        // Should only have one user message
        final userMessages = controller.messages.where((m) => m.isUser);
        expect(userMessages.length, equals(1));
      });

      test('should handle completion error', () async {
        mockClient.shouldFailComplete = true;

        await controller.sendMessage('Hello');

        expect(controller.messages.length, equals(2));
        expect(controller.messages.last.content, contains('Error'));
      });

      test('should set and clear isGenerating', () async {
        final generatingStates = <bool>[];
        controller.addListener(() {
          generatingStates.add(controller.isGenerating);
        });

        await controller.sendMessage('Hello');

        expect(generatingStates.contains(true), isTrue);
        expect(controller.isGenerating, isFalse);
      });
    });

    group('stopGeneration', () {
      setUp(() async {
        await controller.loadModel('/path/to/model.gguf');
      });

      test('should do nothing when not generating', () async {
        await controller.stopGeneration();

        expect(controller.messages, isEmpty);
      });
    });

    group('clearMessages', () {
      setUp(() async {
        await controller.loadModel('/path/to/model.gguf');
      });

      test('should clear all messages', () async {
        await controller.sendMessage('Hello');
        expect(controller.messages, isNotEmpty);

        controller.clearMessages();

        expect(controller.messages, isEmpty);
      });

      test('should notify listeners', () async {
        await controller.sendMessage('Hello');

        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        controller.clearMessages();

        expect(notified, isTrue);
      });
    });

    group('ChangeNotifier Behavior', () {
      test('should support adding listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.loadModel('/path/to/model.gguf');

        expect(callCount, greaterThan(0));
      });

      test('should support removing listeners', () async {
        var callCount = 0;
        void listener() {
          callCount++;
        }

        controller.addListener(listener);
        await controller.loadModel('/path/to/model.gguf');
        final countAfterLoad = callCount;

        controller.removeListener(listener);
        controller.clearMessages();

        expect(callCount, equals(countAfterLoad));
      });

      test('should support multiple listeners', () async {
        var listener1Called = false;
        var listener2Called = false;

        controller.addListener(() {
          listener1Called = true;
        });
        controller.addListener(() {
          listener2Called = true;
        });

        await controller.loadModel('/path/to/model.gguf');

        expect(listener1Called, isTrue);
        expect(listener2Called, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid operations', () async {
        await controller.loadModel('/path/to/model.gguf');
        await controller.sendMessage('A');
        await controller.sendMessage('B');
        await controller.sendMessage('C');

        expect(controller.messages.length, equals(6)); // 3 user + 3 assistant
      });

      test('messages list should be unmodifiable', () async {
        await controller.loadModel('/path/to/model.gguf');
        await controller.sendMessage('Hello');

        expect(
          () => controller.messages.add(
            const ChatMessage(content: 'hack', isUser: true),
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
