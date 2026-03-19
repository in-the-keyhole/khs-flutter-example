import 'package:khs_flutter_example/src/clients/local_fllama_client.dart';

/// Mock fllama client for testing that extends the real class.
class MockFllamaClient extends LocalFllamaClient {
  MockFllamaClient() : super();

  bool _mockIsReady = false;
  bool _mockIsLoading = false;
  bool shouldFailLoad = false;
  bool shouldFailComplete = false;
  String mockResponse = 'Mock response';
  int loadDelayMs = 0;
  int completeDelayMs = 0;

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
      onProgress?.call(i / 10);
    }

    _mockIsLoading = false;
    _mockIsReady = true;
    return true;
  }

  @override
  Future<String> complete(
    String prompt, {
    void Function(String token)? onToken,
    int maxTokens = 256,
    double temperature = 0.7,
    List<String>? stopSequences,
  }) async {
    if (shouldFailComplete) {
      throw Exception('Mock completion error');
    }

    if (completeDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: completeDelayMs));
    }

    // Simulate token streaming
    final words = mockResponse.split(' ');
    for (final word in words) {
      onToken?.call('$word ');
    }

    return mockResponse;
  }

  @override
  Future<String> chat(
    List<RoleContent> messages, {
    void Function(String token)? onToken,
    int maxTokens = 256,
    double temperature = 0.7,
    String? chatTemplate,
  }) async {
    if (shouldFailComplete) {
      throw Exception('Mock completion error');
    }

    if (completeDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: completeDelayMs));
    }

    // Simulate token streaming
    final words = mockResponse.split(' ');
    for (final word in words) {
      onToken?.call('$word ');
    }

    return mockResponse;
  }

  @override
  Future<void> stopCompletion() async {
    // No-op for mock
  }

  @override
  Future<void> release() async {
    _mockIsReady = false;
    _mockIsLoading = false;
  }
}
