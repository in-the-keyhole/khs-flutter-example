import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/download_llm_client.dart';
import 'package:khs_flutter_example/src/components/organisms/model_browser.dart';
import 'package:khs_flutter_example/src/controllers/model_download_controller.dart';
import 'package:khs_flutter_example/src/models/model_registry.dart';

/// Mock download client for testing.
class MockDownloadLlmClient extends DownloadLlmClient {
  MockDownloadLlmClient() : super();

  final Set<String> _existingModels = {};
  bool shouldFailDownload = false;
  bool shouldReturnNull = false;
  int downloadDelayMs = 0;

  void addExistingModel(String filename) {
    _existingModels.add(filename);
  }

  @override
  Future<bool> modelExists(String filename) async {
    return _existingModels.contains(filename);
  }

  @override
  Future<String> getModelPath(String filename) async {
    return '/mock/models/$filename';
  }

  @override
  Future<String?> downloadFile(
    String url, {
    required String filename,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    if (shouldFailDownload) {
      throw Exception('Mock download error');
    }

    if (shouldReturnNull) {
      return null;
    }

    if (downloadDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: downloadDelayMs));
    }

    // Simulate progress
    onProgress?.call(50, 100);
    onProgress?.call(100, 100);

    _existingModels.add(filename);
    return '/mock/models/$filename';
  }

  @override
  void cancelDownload() {
    // No-op for mock
  }

  @override
  Future<bool> deleteModel(String filePath) async {
    final filename = filePath.split('/').last;
    _existingModels.remove(filename);
    return true;
  }
}

void main() {
  group('ModelDownloadController', () {
    late ModelDownloadController controller;
    late MockDownloadLlmClient mockClient;

    setUp(() {
      mockClient = MockDownloadLlmClient();
      controller = ModelDownloadController(mockClient);
    });

    group('Initialization', () {
      test('should create instance', () {
        expect(controller, isA<ModelDownloadController>());
      });

      test('should not be initialized before init', () {
        expect(controller.isInitialized, isFalse);
      });

      test('should be initialized after init', () async {
        await controller.init();
        expect(controller.isInitialized, isTrue);
      });

      test('should populate model items on init', () async {
        await controller.init();
        expect(
          controller.modelItems.length,
          equals(ModelRegistry.models.length),
        );
      });

      test('should mark existing models as downloaded', () async {
        mockClient.addExistingModel(ModelRegistry.models.first.filename);

        await controller.init();

        final firstItem =
            controller.modelItems[ModelRegistry.models.first.id];
        expect(firstItem?.status, equals(ModelDownloadStatus.downloaded));
        expect(firstItem?.localPath, isNotNull);
      });

      test('should mark missing models as notDownloaded', () async {
        await controller.init();

        final firstItem =
            controller.modelItems[ModelRegistry.models.first.id];
        expect(firstItem?.status, equals(ModelDownloadStatus.notDownloaded));
        expect(firstItem?.localPath, isNull);
      });

      test('should notify listeners after init', () async {
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        await controller.init();

        expect(notified, isTrue);
      });
    });

    group('downloadedModels', () {
      test('should return empty when no models downloaded', () async {
        await controller.init();
        expect(controller.downloadedModels, isEmpty);
      });

      test('should return only downloaded models', () async {
        mockClient.addExistingModel(ModelRegistry.models.first.filename);

        await controller.init();

        expect(controller.downloadedModels.length, equals(1));
        expect(
          controller.downloadedModels.first.model.id,
          equals(ModelRegistry.models.first.id),
        );
      });
    });

    group('downloadModel', () {
      setUp(() async {
        await controller.init();
      });

      test('should download model successfully', () async {
        final model = ModelRegistry.models.first;

        await controller.downloadModel(model);

        final item = controller.modelItems[model.id];
        expect(item?.status, equals(ModelDownloadStatus.downloaded));
        expect(item?.localPath, isNotNull);
      });

      test('should notify listeners during download', () async {
        final model = ModelRegistry.models.first;
        var notifyCount = 0;
        controller.addListener(() {
          notifyCount++;
        });

        await controller.downloadModel(model);

        // At least: downloading + progress updates + completed
        expect(notifyCount, greaterThan(1));
      });

      test('should handle download failure', () async {
        mockClient.shouldFailDownload = true;
        final model = ModelRegistry.models.first;

        await controller.downloadModel(model);

        final item = controller.modelItems[model.id];
        expect(item?.status, equals(ModelDownloadStatus.notDownloaded));
      });

      test('should handle null return (cancelled)', () async {
        mockClient.shouldReturnNull = true;
        final model = ModelRegistry.models.first;

        await controller.downloadModel(model);

        final item = controller.modelItems[model.id];
        expect(item?.status, equals(ModelDownloadStatus.notDownloaded));
      });
    });

    group('cancelDownload', () {
      setUp(() async {
        await controller.init();
      });

      test('should reset model status on cancel', () {
        final model = ModelRegistry.models.first;

        controller.cancelDownload(model);

        final item = controller.modelItems[model.id];
        expect(item?.status, equals(ModelDownloadStatus.notDownloaded));
        expect(item?.downloadProgress, equals(0.0));
      });

      test('should notify listeners', () {
        final model = ModelRegistry.models.first;
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        controller.cancelDownload(model);

        expect(notified, isTrue);
      });
    });

    group('deleteModel', () {
      setUp(() async {
        mockClient.addExistingModel(ModelRegistry.models.first.filename);
        await controller.init();
      });

      test('should delete model and update status', () async {
        final model = ModelRegistry.models.first;
        final item = controller.modelItems[model.id];
        expect(item?.status, equals(ModelDownloadStatus.downloaded));

        await controller.deleteModel(model, item!.localPath!);

        expect(item.status, equals(ModelDownloadStatus.notDownloaded));
        expect(item.localPath, isNull);
      });

      test('should notify listeners', () async {
        final model = ModelRegistry.models.first;
        final item = controller.modelItems[model.id]!;

        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        await controller.deleteModel(model, item.localPath!);

        expect(notified, isTrue);
      });
    });

    group('modelItems', () {
      test('should return unmodifiable map', () async {
        await controller.init();

        expect(
          () => (controller.modelItems as Map)['test'] =
              ModelBrowserItem(model: ModelRegistry.models.first),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
