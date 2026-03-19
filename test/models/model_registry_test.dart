import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/models/model_registry.dart';

void main() {
  group('ModelInfo', () {
    test('should create instance with required fields', () {
      const model = ModelInfo(
        id: 'test-model',
        name: 'Test Model',
        description: 'A test model',
        sizeBytes: 1024 * 1024 * 1024,
        downloadUrl: 'https://example.com/model.gguf',
        quantization: 'Q4_K_M',
      );

      expect(model.id, equals('test-model'));
      expect(model.name, equals('Test Model'));
      expect(model.description, equals('A test model'));
      expect(model.sizeBytes, equals(1024 * 1024 * 1024));
      expect(model.downloadUrl, equals('https://example.com/model.gguf'));
      expect(model.quantization, equals('Q4_K_M'));
    });

    test('should create instance with optional fields', () {
      const model = ModelInfo(
        id: 'test-model',
        name: 'Test Model',
        description: 'A test model',
        sizeBytes: 1024,
        downloadUrl: 'https://example.com/model.gguf',
        quantization: 'Q4_K_M',
        parameters: '1.1B',
        recommended: true,
      );

      expect(model.parameters, equals('1.1B'));
      expect(model.recommended, isTrue);
    });

    test('should default recommended to false', () {
      const model = ModelInfo(
        id: 'test-model',
        name: 'Test Model',
        description: 'A test model',
        sizeBytes: 1024,
        downloadUrl: 'https://example.com/model.gguf',
        quantization: 'Q4_K_M',
      );

      expect(model.recommended, isFalse);
    });

    group('sizeString', () {
      test('should format bytes as KB', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1024 * 500, // 500 KB
          downloadUrl: 'https://example.com/model.gguf',
          quantization: 'Q4',
        );

        expect(model.sizeString, equals('500 KB'));
      });

      test('should format bytes as MB', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1024 * 1024 * 50, // 50 MB
          downloadUrl: 'https://example.com/model.gguf',
          quantization: 'Q4',
        );

        expect(model.sizeString, equals('50 MB'));
      });

      test('should format bytes as GB with one decimal', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1024 * 1024 * 1024 * 2, // 2 GB
          downloadUrl: 'https://example.com/model.gguf',
          quantization: 'Q4',
        );

        expect(model.sizeString, equals('2.0 GB'));
      });

      test('should format fractional GB correctly', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1600000000, // ~1.5 GB
          downloadUrl: 'https://example.com/model.gguf',
          quantization: 'Q4',
        );

        expect(model.sizeString, contains('GB'));
        expect(model.sizeString, contains('1.'));
      });
    });

    group('filename', () {
      test('should extract filename from URL', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1024,
          downloadUrl: 'https://example.com/path/to/model.gguf',
          quantization: 'Q4',
        );

        expect(model.filename, equals('model.gguf'));
      });

      test('should handle URL with query parameters', () {
        const model = ModelInfo(
          id: 'test',
          name: 'Test',
          description: 'Test',
          sizeBytes: 1024,
          downloadUrl: 'https://example.com/path/model.gguf?token=abc',
          quantization: 'Q4',
        );

        expect(model.filename, equals('model.gguf?token=abc'));
      });
    });
  });

  group('ModelRegistry', () {
    test('should have models list', () {
      expect(ModelRegistry.models, isNotEmpty);
    });

    test('should have at least 5 models', () {
      expect(ModelRegistry.models.length, greaterThanOrEqualTo(5));
    });

    test('all models should have valid IDs', () {
      for (final model in ModelRegistry.models) {
        expect(model.id, isNotEmpty);
      }
    });

    test('all models should have valid names', () {
      for (final model in ModelRegistry.models) {
        expect(model.name, isNotEmpty);
      }
    });

    test('all models should have valid descriptions', () {
      for (final model in ModelRegistry.models) {
        expect(model.description, isNotEmpty);
      }
    });

    test('all models should have positive size', () {
      for (final model in ModelRegistry.models) {
        expect(model.sizeBytes, greaterThan(0));
      }
    });

    test('all models should have valid download URLs', () {
      for (final model in ModelRegistry.models) {
        expect(model.downloadUrl, startsWith('https://'));
        expect(model.downloadUrl, contains('.gguf'));
      }
    });

    test('all models should have quantization', () {
      for (final model in ModelRegistry.models) {
        expect(model.quantization, isNotEmpty);
      }
    });

    group('recommendedModels', () {
      test('should return recommended models', () {
        final recommended = ModelRegistry.recommendedModels;
        expect(recommended, isNotEmpty);
      });

      test('all recommended models should have recommended flag', () {
        final recommended = ModelRegistry.recommendedModels;
        for (final model in recommended) {
          expect(model.recommended, isTrue);
        }
      });

      test('should include TinyLlama and Phi-2', () {
        final recommended = ModelRegistry.recommendedModels;
        final ids = recommended.map((m) => m.id).toList();

        expect(ids, contains('tinyllama-1.1b-q4'));
        expect(ids, contains('phi-2-q4'));
      });
    });

    group('getById', () {
      test('should return model by ID', () {
        final model = ModelRegistry.getById('tinyllama-1.1b-q4');

        expect(model, isNotNull);
        expect(model?.id, equals('tinyllama-1.1b-q4'));
      });

      test('should return null for non-existent ID', () {
        final model = ModelRegistry.getById('non-existent-id');

        expect(model, isNull);
      });

      test('should find all models by their IDs', () {
        for (final original in ModelRegistry.models) {
          final found = ModelRegistry.getById(original.id);
          expect(found, isNotNull);
          expect(found?.id, equals(original.id));
        }
      });
    });

    group('modelsBySize', () {
      test('should return models sorted by size', () {
        final sorted = ModelRegistry.modelsBySize;

        expect(sorted, isNotEmpty);
        expect(sorted.length, equals(ModelRegistry.models.length));

        // Check sorting
        for (var i = 0; i < sorted.length - 1; i++) {
          expect(
            sorted[i].sizeBytes,
            lessThanOrEqualTo(sorted[i + 1].sizeBytes),
          );
        }
      });

      test('should have smallest model first', () {
        final sorted = ModelRegistry.modelsBySize;
        final sizes = sorted.map((m) => m.sizeBytes).toList();

        expect(sizes.first, equals(sizes.reduce((a, b) => a < b ? a : b)));
      });

      test('should have largest model last', () {
        final sorted = ModelRegistry.modelsBySize;
        final sizes = sorted.map((m) => m.sizeBytes).toList();

        expect(sizes.last, equals(sizes.reduce((a, b) => a > b ? a : b)));
      });

      test('should not modify original models list', () {
        final original = List<ModelInfo>.from(ModelRegistry.models);
        ModelRegistry.modelsBySize;

        expect(ModelRegistry.models, equals(original));
      });
    });

    group('Specific Models', () {
      test('TinyLlama should exist', () {
        final model = ModelRegistry.getById('tinyllama-1.1b-q4');

        expect(model, isNotNull);
        expect(model?.name, contains('TinyLlama'));
        expect(model?.parameters, equals('1.1B'));
      });

      test('Phi-2 should exist', () {
        final model = ModelRegistry.getById('phi-2-q4');

        expect(model, isNotNull);
        expect(model?.name, contains('Phi-2'));
        expect(model?.parameters, equals('2.7B'));
      });
    });
  });
}
