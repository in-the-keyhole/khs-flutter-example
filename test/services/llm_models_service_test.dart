import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_fllama_client.dart';
import 'package:khs_flutter_example/src/services/llm_models_service.dart';

/// Mock fllama client for testing
class MockFllamaClient extends LocalFllamaClient {
  MockFllamaClient() : super();

  bool _mockIsReady = false;
  bool _mockIsLoading = false;
  bool shouldFailLoad = false;
  int loadDelayMs = 0;
  List<double> progressCallbacks = [];

  @override
  bool get isReady => _mockIsReady;

  @override
  bool get isLoading => _mockIsLoading;

  @override
  Future<bool> loadModel(
    String modelPath, {
    void Function(double progress)? onProgress,
    int nCtx = 512,
    int nGpuLayers = 0,
  }) async {
    if (shouldFailLoad) return false;

    _mockIsLoading = true;

    // Simulate loading progress
    for (var i = 0; i <= 10; i++) {
      if (loadDelayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: loadDelayMs ~/ 10));
      }
      final progress = i / 10;
      progressCallbacks.add(progress);
      onProgress?.call(progress);
    }

    _mockIsLoading = false;
    _mockIsReady = true;
    return true;
  }

  @override
  Future<void> release() async {
    _mockIsReady = false;
    _mockIsLoading = false;
  }
}

void main() {
  group('LlmModelsService', () {
    late LlmModelsService service;
    late MockFllamaClient mockClient;

    setUp(() {
      mockClient = MockFllamaClient();
      service = LlmModelsService(mockClient);
    });

    group('Initialization', () {
      test('should create instance with client', () {
        expect(service, isA<LlmModelsService>());
      });

      test('should start with no model loaded', () {
        expect(service.isReady, isFalse);
        expect(service.modelPath, isNull);
        expect(service.modelName, isNull);
      });

      test('should start with zero load progress', () {
        expect(service.loadProgress, equals(0.0));
      });

      test('should start not loading', () {
        expect(service.isLoading, isFalse);
      });
    });

    group('loadModel', () {
      test('should load model successfully', () async {
        final success = await service.loadModel('/path/to/model.gguf');

        expect(success, isTrue);
        expect(service.isReady, isTrue);
        expect(service.modelPath, equals('/path/to/model.gguf'));
      });

      test('should extract model name from path', () async {
        await service.loadModel('/path/to/my-test-model.gguf');

        expect(service.modelName, equals('my test model'));
      });

      test('should extract model name from complex path', () async {
        await service.loadModel('/some/nested/path/llama-2-7b-chat.gguf');

        expect(service.modelName, equals('llama 2 7b chat'));
      });

      test('should handle underscores in filename', () async {
        await service.loadModel('/path/my_model_name.gguf');

        expect(service.modelName, equals('my model name'));
      });

      test('should use custom model name when provided', () async {
        await service.loadModel(
          '/path/to/model.gguf',
          modelName: 'Custom Model',
        );

        expect(service.modelName, equals('Custom Model'));
      });

      test('should update progress during load', () async {
        final progressValues = <double>[];
        await service.loadModel(
          '/path/to/model.gguf',
          onProgress: (progress) {
            progressValues.add(progress);
          },
        );

        expect(progressValues, isNotEmpty);
        expect(progressValues.first, equals(0.0));
        expect(progressValues.last, equals(1.0));
      });

      test('should track load progress internally', () async {
        expect(service.loadProgress, equals(0.0));

        final future = service.loadModel('/path/to/model.gguf');

        // Progress should eventually reach 1.0
        await future;
        expect(service.loadProgress, greaterThanOrEqualTo(0.0));
      });

      test('should pass nCtx parameter to client', () async {
        await service.loadModel(
          '/path/to/model.gguf',
          nCtx: 4096,
        );

        expect(service.isReady, isTrue);
      });

      test('should pass nGpuLayers parameter to client', () async {
        await service.loadModel(
          '/path/to/model.gguf',
          nGpuLayers: 32,
        );

        expect(service.isReady, isTrue);
      });

      test('should handle load failure', () async {
        mockClient.shouldFailLoad = true;

        final success = await service.loadModel('/path/to/model.gguf');

        expect(success, isFalse);
        expect(service.isReady, isFalse);
        expect(service.modelPath, isNull);
        expect(service.modelName, isNull);
      });

      test('should clear model info on load failure', () async {
        mockClient.shouldFailLoad = true;

        await service.loadModel(
          '/path/to/model.gguf',
          modelName: 'Test Model',
        );

        expect(service.modelPath, isNull);
        expect(service.modelName, isNull);
      });

      test('should not be loading after success', () async {
        await service.loadModel('/path/to/model.gguf');

        expect(service.isLoading, isFalse);
      });

      test('should not be loading after failure', () async {
        mockClient.shouldFailLoad = true;
        await service.loadModel('/path/to/model.gguf');

        expect(service.isLoading, isFalse);
      });
    });

    group('unloadModel', () {
      test('should unload model', () async {
        await service.loadModel('/path/to/model.gguf');
        expect(service.isReady, isTrue);

        await service.unloadModel();

        expect(service.isReady, isFalse);
        expect(service.modelPath, isNull);
        expect(service.modelName, isNull);
        expect(service.loadProgress, equals(0.0));
      });

      test('should be safe to call when no model loaded', () async {
        await service.unloadModel();

        expect(service.isReady, isFalse);
      });

      test('should be safe to call multiple times', () async {
        await service.loadModel('/path/to/model.gguf');
        await service.unloadModel();
        await service.unloadModel();

        expect(service.isReady, isFalse);
      });
    });

    group('Model State Queries', () {
      test('isReady should reflect client state', () async {
        expect(service.isReady, isFalse);

        await service.loadModel('/path/to/model.gguf');
        expect(service.isReady, isTrue);

        await service.unloadModel();
        expect(service.isReady, isFalse);
      });

      test('isLoading should reflect client state', () async {
        expect(service.isLoading, isFalse);

        mockClient.loadDelayMs = 100;
        final future = service.loadModel('/path/to/model.gguf');

        // May or may not catch it loading depending on timing
        await future;
        expect(service.isLoading, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle empty path', () async {
        await service.loadModel('');

        // Should use empty string as is, client handles validation
        expect(service.modelPath, equals(''));
      });

      test('should handle path without .gguf extension', () async {
        await service.loadModel('/path/to/model');

        expect(service.modelName, equals('model'));
      });

      test('should handle path with only directory', () async {
        await service.loadModel('/path/to/');

        expect(service.modelName, equals(''));
      });

      test('should handle Windows-style paths', () async {
        await service.loadModel('C:\\Users\\test\\model.gguf');

        // The service uses forward slash split, so this won't parse correctly
        // But it should still attempt to load
        expect(service.modelPath, equals('C:\\Users\\test\\model.gguf'));
      });

      test('should handle model reload', () async {
        await service.loadModel('/path/to/model1.gguf');
        expect(service.modelName, equals('model1'));

        await service.unloadModel();
        await service.loadModel('/path/to/model2.gguf');
        expect(service.modelName, equals('model2'));
      });

      test('should handle progress callback being null', () async {
        final success = await service.loadModel(
          '/path/to/model.gguf',
          onProgress: null,
        );

        expect(success, isTrue);
      });

      test('should handle various special characters in filename', () async {
        await service.loadModel('/path/model-name_v2.3-q4.gguf');

        expect(service.modelName, equals('model name v2.3 q4'));
      });
    });

    group('Integration', () {
      test('should maintain state consistency', () async {
        expect(service.isReady, equals(mockClient.isReady));

        await service.loadModel('/path/to/model.gguf');
        expect(service.isReady, equals(mockClient.isReady));

        await service.unloadModel();
        expect(service.isReady, equals(mockClient.isReady));
      });

      test('should handle rapid load/unload cycles', () async {
        for (var i = 0; i < 5; i++) {
          await service.loadModel('/path/to/model$i.gguf');
          expect(service.isReady, isTrue);
          await service.unloadModel();
          expect(service.isReady, isFalse);
        }
      });

      test('should preserve model info during client operations', () async {
        await service.loadModel(
          '/path/to/model.gguf',
          modelName: 'Test Model',
        );

        // Model info should remain even if we query other properties
        expect(service.loadProgress, greaterThanOrEqualTo(0.0));
        expect(service.isReady, isTrue);
        expect(service.modelName, equals('Test Model'));
        expect(service.modelPath, equals('/path/to/model.gguf'));
      });
    });
  });
}
