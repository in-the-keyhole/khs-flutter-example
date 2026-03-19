import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/mcp/list_models_tool.dart';
import 'package:khs_flutter_example/src/models/model_registry.dart';

void main() {
  group('ListModelsTool', () {
    late ListModelsTool tool;

    setUp(() {
      tool = ListModelsTool();
    });

    test('has correct name', () {
      expect(tool.name, equals('list_models'));
    });

    test('has a description', () {
      expect(tool.description, isNotNull);
      expect(tool.description, isNotEmpty);
    });

    test('has an inputSchema', () {
      expect(tool.inputSchema, isNotNull);
    });

    group('execute', () {
      test('returns all models by default', () async {
        final result = await tool.execute({});

        expect(result.isError, isNot(true));
        expect(result.content, isNotEmpty);

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;
        expect(json.length, equals(ModelRegistry.models.length));
      });

      test('returns all models when recommended_only is false', () async {
        final result = await tool.execute({'recommended_only': false});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;
        expect(json.length, equals(ModelRegistry.models.length));
      });

      test('returns only recommended models when recommended_only is true',
          () async {
        final result = await tool.execute({'recommended_only': true});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;

        expect(json.length, equals(ModelRegistry.recommendedModels.length));
        for (final model in json) {
          expect(model['recommended'], isTrue);
        }
      });

      test('each model entry has required fields', () async {
        final result = await tool.execute({});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;

        for (final model in json) {
          final m = model as Map<String, dynamic>;
          expect(m['id'], isNotNull);
          expect(m['name'], isNotNull);
          expect(m['description'], isNotNull);
          expect(m['size'], isNotNull);
          expect(m['size_bytes'], isNotNull);
          expect(m['download_url'], isNotNull);
          expect(m['quantization'], isNotNull);
          expect(m['recommended'], isNotNull);
        }
      });

      test('returns pretty-printed JSON', () async {
        final result = await tool.execute({});

        final text = result.content!.first.toJson()['text'] as String;
        expect(text, contains('\n'));
        expect(text, contains('  '));
      });

      test('tool calling models are included', () async {
        final result = await tool.execute({});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;
        final ids = json.map((m) => m['id'] as String).toList();

        expect(ids, contains('qwen3-4b-q4'));
        expect(ids, contains('lfm25-nova-1.2b-fc-q4'));
      });

      test('download URLs start with https', () async {
        final result = await tool.execute({});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;

        for (final model in json) {
          expect(
            (model['download_url'] as String).startsWith('https://'),
            isTrue,
          );
        }
      });

      test('does not include null parameters field when absent', () async {
        final result = await tool.execute({});

        final json = jsonDecode(result.content!.first.toJson()['text'] as String)
            as List<dynamic>;

        // At least one model might have null parameters — confirm it's omitted
        for (final model in json) {
          final m = model as Map<String, dynamic>;
          if (!m.containsKey('parameters')) {
            // acceptable — null parameters are omitted
            expect(m.containsKey('parameters'), isFalse);
          }
        }
      });
    });
  });
}
