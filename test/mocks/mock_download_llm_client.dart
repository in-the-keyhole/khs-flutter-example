import 'package:khs_flutter_example/src/clients/download_llm_client.dart';

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
      await Future<void>.delayed(Duration(milliseconds: downloadDelayMs));
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
