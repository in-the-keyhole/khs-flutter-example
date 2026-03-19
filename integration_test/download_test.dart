import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:khs_flutter_example/src/clients/download_llm_client.dart';

/// Integration test for the download functionality.
///
/// This test verifies that the app can successfully download files
/// from the internet to the device's storage.
///
/// Run with: flutter test integration_test/download_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download Integration Tests', () {
    late DownloadLlmClient downloadClient;
    late Directory modelsDir;

    setUp(() async {
      downloadClient = DownloadLlmClient();
      modelsDir = await downloadClient.getModelsDirectory();
    });

    tearDown(() async {
      // Clean up any test files
      await downloadClient.cleanupPartialDownloads();
    });

    testWidgets('should create models directory', (tester) async {
      final dir = await downloadClient.getModelsDirectory();

      expect(dir.existsSync(), isTrue);
      expect(dir.path, contains('models'));
    });

    testWidgets('should download a small test file', (tester) async {
      // Use a small, reliable test file (GitHub raw file)
      const testUrl =
          'https://raw.githubusercontent.com/anthropics/anthropic-cookbook/main/README.md';
      const testFilename = 'test_download.md';

      // Track progress
      final progressValues = <double>[];
      var lastProgress = 0.0;

      final path = await downloadClient.downloadFile(
        testUrl,
        filename: testFilename,
        onProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            if (progress > lastProgress) {
              progressValues.add(progress);
              lastProgress = progress;
            }
          }
        },
      );

      // Verify download succeeded
      expect(path, isNotNull);
      expect(path, endsWith(testFilename));

      // Verify file exists
      final file = File(path!);
      expect(file.existsSync(), isTrue);

      // Verify file has content
      final size = await file.length();
      expect(size, greaterThan(0));

      // Verify progress was reported
      expect(progressValues, isNotEmpty);

      // Clean up
      await file.delete();
    });

    testWidgets('should report accurate progress', (tester) async {
      const testUrl =
          'https://raw.githubusercontent.com/anthropics/anthropic-cookbook/main/README.md';
      const testFilename = 'progress_test.md';

      int totalReported = 0;
      int receivedReported = 0;

      await downloadClient.downloadFile(
        testUrl,
        filename: testFilename,
        onProgress: (received, total) {
          receivedReported = received;
          totalReported = total;
        },
      );

      // Final progress should equal total
      expect(receivedReported, equals(totalReported));
      expect(totalReported, greaterThan(0));

      // Clean up
      final path = await downloadClient.getModelPath(testFilename);
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    });

    testWidgets('should handle cancel during download', (tester) async {
      // Use a larger file to give time to cancel
      const testUrl =
          'https://raw.githubusercontent.com/anthropics/anthropic-cookbook/main/README.md';
      const testFilename = 'cancel_test.md';

      // Start download
      final downloadFuture = downloadClient.downloadFile(
        testUrl,
        filename: testFilename,
      );

      // Cancel immediately
      downloadClient.cancelDownload();

      final result = await downloadFuture;

      // Result should be null (cancelled)
      expect(result, isNull);

      // Clean up any partial file
      final path = await downloadClient.getModelPath(testFilename);
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }

      // Clean up .download file
      final partialFile = File('$path.download');
      if (partialFile.existsSync()) {
        await partialFile.delete();
      }
    });

    testWidgets('should skip download if file already exists', (tester) async {
      const testFilename = 'existing_test.md';

      // Create the file first
      final path = await downloadClient.getModelPath(testFilename);
      final file = File(path);
      await file.writeAsString('Existing content');

      // Verify it exists
      expect(await downloadClient.modelExists(testFilename), isTrue);

      // Try to download - should return immediately with existing path
      final result = await downloadClient.downloadFile(
        'https://example.com/fake.md', // URL shouldn't be accessed
        filename: testFilename,
      );

      expect(result, equals(path));

      // Verify content wasn't changed
      final content = await file.readAsString();
      expect(content, equals('Existing content'));

      // Clean up
      await file.delete();
    });

    testWidgets('should handle HTTP errors gracefully', (tester) async {
      const badUrl = 'https://httpstat.us/404';
      const testFilename = 'error_test.md';

      expect(
        () => downloadClient.downloadFile(badUrl, filename: testFilename),
        throwsA(isA<HttpException>()),
      );
    });

    testWidgets('should list downloaded model files', (tester) async {
      // Create some test model files
      final path1 = await downloadClient.getModelPath('model1.gguf');
      final path2 = await downloadClient.getModelPath('model2.gguf');
      final path3 = await downloadClient.getModelPath('notamodel.txt');

      await File(path1).writeAsString('model1');
      await File(path2).writeAsString('model2');
      await File(path3).writeAsString('not a model');

      final models = await downloadClient.listDownloadedModels();

      expect(models.length, equals(2));
      expect(models.any((f) => f.path.endsWith('model1.gguf')), isTrue);
      expect(models.any((f) => f.path.endsWith('model2.gguf')), isTrue);
      expect(models.any((f) => f.path.endsWith('notamodel.txt')), isFalse);

      // Clean up
      await File(path1).delete();
      await File(path2).delete();
      await File(path3).delete();
    });

    testWidgets('should delete model files', (tester) async {
      const testFilename = 'todelete.gguf';
      final path = await downloadClient.getModelPath(testFilename);

      // Create a test file
      await File(path).writeAsString('test');
      expect(await downloadClient.modelExists(testFilename), isTrue);

      // Delete it
      final deleted = await downloadClient.deleteModel(path);

      expect(deleted, isTrue);
      expect(await downloadClient.modelExists(testFilename), isFalse);
    });

    testWidgets('should get model file size', (tester) async {
      const testFilename = 'sized.gguf';
      final path = await downloadClient.getModelPath(testFilename);

      // Create a test file with known size
      final testContent = List.filled(1234, 65); // 1234 bytes of 'A'
      await File(path).writeAsBytes(testContent);

      final size = await downloadClient.getModelSize(path);

      expect(size, equals(1234));

      // Clean up
      await File(path).delete();
    });

    testWidgets('should clean up partial downloads', (tester) async {
      // Create some partial download files
      final partial1 = File('${modelsDir.path}/partial1.gguf.download');
      final partial2 = File('${modelsDir.path}/partial2.gguf.download');
      final complete = File('${modelsDir.path}/complete.gguf');

      await partial1.writeAsString('partial1');
      await partial2.writeAsString('partial2');
      await complete.writeAsString('complete');

      // Clean up partials
      await downloadClient.cleanupPartialDownloads();

      // Verify partials are deleted
      expect(partial1.existsSync(), isFalse);
      expect(partial2.existsSync(), isFalse);

      // Verify complete file is preserved
      expect(complete.existsSync(), isTrue);

      // Clean up
      await complete.delete();
    });
  });
}
