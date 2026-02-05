import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:khs_flutter_example/src/clients/download_llm_client.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock path provider for testing
class MockPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String testPath;

  MockPathProvider(this.testPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => testPath;
}

/// Mock HTTP client for testing
class MockHttpClient extends http.BaseClient {
  final Map<String, MockResponse> responses = {};
  http.BaseRequest? lastRequest;
  bool shouldFail = false;
  String? failureMessage;

  void mockResponse(String url, MockResponse response) {
    responses[url] = response;
  }

  void setFailure(String message) {
    shouldFail = true;
    failureMessage = message;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;

    if (shouldFail) {
      throw HttpException(failureMessage ?? 'Mock failure');
    }

    final response = responses[request.url.toString()];
    if (response == null) {
      return http.StreamedResponse(
        Stream.value(Uint8List(0)),
        404,
      );
    }

    return response.toStreamedResponse();
  }
}

/// Mock response for testing
class MockResponse {
  final int statusCode;
  final Uint8List body;
  final Map<String, String> headers;
  final int chunkSize;
  final Duration? delayPerChunk;

  MockResponse({
    this.statusCode = 200,
    required this.body,
    this.headers = const {},
    this.chunkSize = 1024,
    this.delayPerChunk,
  });

  http.StreamedResponse toStreamedResponse() {
    final controller = StreamController<List<int>>();

    // Send body in chunks
    () async {
      for (var i = 0; i < body.length; i += chunkSize) {
        if (delayPerChunk != null) {
          await Future.delayed(delayPerChunk!);
        }
        final end = (i + chunkSize > body.length) ? body.length : i + chunkSize;
        controller.add(body.sublist(i, end));
      }
      await controller.close();
    }();

    return http.StreamedResponse(
      controller.stream,
      statusCode,
      contentLength: body.length,
      headers: headers,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelDownloadClient', () {
    late DownloadLlmClient downloadClient;
    late MockHttpClient mockHttpClient;
    late Directory tempDir;

    setUp(() async {
      // Create temp directory for tests
      tempDir = await Directory.systemTemp.createTemp('download_test_');

      // Set up mock path provider
      PathProviderPlatform.instance = MockPathProvider(tempDir.path);

      mockHttpClient = MockHttpClient();
      downloadClient = DownloadLlmClient(httpClient: mockHttpClient);
    });

    tearDown(() async {
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Initialization', () {
      test('should create instance', () {
        expect(downloadClient, isA<DownloadLlmClient>());
      });

      test('should create instance without http client (uses default)', () {
        final client = DownloadLlmClient();
        expect(client, isA<DownloadLlmClient>());
      });
    });

    group('getModelsDirectory', () {
      test('should create and return models directory', () async {
        final modelsDir = await downloadClient.getModelsDirectory();
        expect(await modelsDir.exists(), isTrue);
        expect(modelsDir.path, contains('models'));
      });

      test('should reuse existing models directory', () async {
        final dir1 = await downloadClient.getModelsDirectory();
        final dir2 = await downloadClient.getModelsDirectory();
        expect(dir1.path, equals(dir2.path));
      });
    });

    group('downloadFile', () {
      test('should download file successfully', () async {
        const url = 'https://example.com/model.gguf';
        final testData = Uint8List.fromList(utf8.encode('test model data'));

        mockHttpClient.mockResponse(
          url,
          MockResponse(body: testData, statusCode: 200),
        );

        final path = await downloadClient.downloadFile(
          url,
          filename: 'model.gguf',
        );

        expect(path, isNotNull);
        expect(path, contains('model.gguf'));

        final file = File(path!);
        expect(await file.exists(), isTrue);
        expect(await file.readAsBytes(), equals(testData));
      });

      test('should report progress during download', () async {
        const url = 'https://example.com/model.gguf';
        final testData = Uint8List(10000); // 10KB

        mockHttpClient.mockResponse(
          url,
          MockResponse(body: testData, statusCode: 200, chunkSize: 1000),
        );

        final progressValues = <double>[];

        await downloadClient.downloadFile(
          url,
          filename: 'model.gguf',
          onProgress: (received, total) {
            if (total > 0) {
              progressValues.add(received / total);
            }
          },
        );

        // Should have received multiple progress updates
        expect(progressValues, isNotEmpty);
        // Last progress should be 100%
        expect(progressValues.last, equals(1.0));
      });

      test('should return existing file path if file already exists', () async {
        const url = 'https://example.com/model.gguf';
        final testData = Uint8List.fromList(utf8.encode('existing data'));

        // Create the file first
        final modelsDir = await downloadClient.getModelsDirectory();
        final existingFile = File('${modelsDir.path}/model.gguf');
        await existingFile.writeAsBytes(testData);

        final path = await downloadClient.downloadFile(
          url,
          filename: 'model.gguf',
        );

        expect(path, equals(existingFile.path));
        // Verify HTTP request was not made
        expect(mockHttpClient.lastRequest, isNull);
      });

      test('should handle 404 response', () async {
        const url = 'https://example.com/notfound.gguf';

        // Don't mock response - will return 404 by default

        expect(
          () => downloadClient.downloadFile(url, filename: 'notfound.gguf'),
          throwsA(isA<HttpException>()),
        );
      });

      test('should handle network failure', () async {
        const url = 'https://example.com/model.gguf';
        mockHttpClient.setFailure('Network error');

        expect(
          () => downloadClient.downloadFile(url, filename: 'model.gguf'),
          throwsA(isA<HttpException>()),
        );
      });
    });

    group('cancelDownload', () {
      test('should cancel ongoing download', () async {
        const url = 'https://example.com/large.gguf';
        final testData = Uint8List(100000); // 100KB

        mockHttpClient.mockResponse(
          url,
          MockResponse(
            body: testData,
            statusCode: 200,
            chunkSize: 1000,
            delayPerChunk: const Duration(milliseconds: 10),
          ),
        );

        // Start download and cancel after a short delay
        final downloadFuture = downloadClient.downloadFile(
          url,
          filename: 'large.gguf',
        );

        // Cancel after download starts
        await Future.delayed(const Duration(milliseconds: 50));
        downloadClient.cancelDownload();

        final result = await downloadFuture;
        expect(result, isNull);
      });
    });

    group('modelExists', () {
      test('should return true if model exists', () async {
        final modelsDir = await downloadClient.getModelsDirectory();
        final file = File('${modelsDir.path}/test.gguf');
        await file.writeAsBytes([1, 2, 3]);

        final exists = await downloadClient.modelExists('test.gguf');
        expect(exists, isTrue);
      });

      test('should return false if model does not exist', () async {
        final exists = await downloadClient.modelExists('nonexistent.gguf');
        expect(exists, isFalse);
      });
    });

    group('getModelPath', () {
      test('should return full path for model filename', () async {
        final path = await downloadClient.getModelPath('test.gguf');
        expect(path, contains('models'));
        expect(path, endsWith('test.gguf'));
      });
    });

    group('deleteModel', () {
      test('should delete existing model', () async {
        final modelsDir = await downloadClient.getModelsDirectory();
        final file = File('${modelsDir.path}/todelete.gguf');
        await file.writeAsBytes([1, 2, 3]);

        final deleted = await downloadClient.deleteModel(file.path);
        expect(deleted, isTrue);
        expect(await file.exists(), isFalse);
      });

      test('should return false for non-existent model', () async {
        final deleted = await downloadClient.deleteModel('/fake/path.gguf');
        expect(deleted, isFalse);
      });
    });

    group('listDownloadedModels', () {
      test('should list downloaded gguf files', () async {
        final modelsDir = await downloadClient.getModelsDirectory();

        // Create some test files
        await File('${modelsDir.path}/model1.gguf').writeAsBytes([1]);
        await File('${modelsDir.path}/model2.gguf').writeAsBytes([2]);
        await File('${modelsDir.path}/other.txt').writeAsBytes([3]);

        final models = await downloadClient.listDownloadedModels();

        expect(models.length, equals(2));
        expect(models.any((f) => f.path.endsWith('model1.gguf')), isTrue);
        expect(models.any((f) => f.path.endsWith('model2.gguf')), isTrue);
        expect(models.any((f) => f.path.endsWith('other.txt')), isFalse);
      });

      test('should return empty list when no models exist', () async {
        final models = await downloadClient.listDownloadedModels();
        expect(models, isEmpty);
      });
    });

    group('cleanupPartialDownloads', () {
      test('should remove partial download files', () async {
        final modelsDir = await downloadClient.getModelsDirectory();

        // Create partial download files
        final partial1 = File('${modelsDir.path}/model1.gguf.download');
        final partial2 = File('${modelsDir.path}/model2.gguf.download');
        final complete = File('${modelsDir.path}/model3.gguf');

        await partial1.writeAsBytes([1]);
        await partial2.writeAsBytes([2]);
        await complete.writeAsBytes([3]);

        await downloadClient.cleanupPartialDownloads();

        expect(await partial1.exists(), isFalse);
        expect(await partial2.exists(), isFalse);
        expect(await complete.exists(), isTrue);
      });
    });

    group('getModelSize', () {
      test('should return file size for existing model', () async {
        final modelsDir = await downloadClient.getModelsDirectory();
        final testData = Uint8List(1234);
        final file = File('${modelsDir.path}/sized.gguf');
        await file.writeAsBytes(testData);

        final size = await downloadClient.getModelSize(file.path);
        expect(size, equals(1234));
      });

      test('should return null for non-existent model', () async {
        final size = await downloadClient.getModelSize('/fake/path.gguf');
        expect(size, isNull);
      });
    });
  });
}
