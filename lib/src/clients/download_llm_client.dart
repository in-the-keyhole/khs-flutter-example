import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// A client that handles downloading LLM model files with progress tracking.
///
/// This client supports resumable downloads and progress callbacks.
class DownloadLlmClient {
  DownloadLlmClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  bool _isCancelled = false;

  /// Downloads a file from [url] to the app's models directory.
  ///
  /// [filename] the name to save the file as.
  /// [onProgress] callback with (bytesReceived, totalBytes).
  /// [onComplete] callback when download completes with the file path.
  /// [onError] callback if an error occurs.
  ///
  /// Returns the path to the downloaded file.
  Future<String?> downloadFile(
    String url, {
    required String filename,
    void Function(int bytesReceived, int totalBytes)? onProgress,
  }) async {
    _isCancelled = false;
    debugPrint('[ModelDownloadClient] downloadFile called');
    debugPrint('[ModelDownloadClient] URL: $url');
    debugPrint('[ModelDownloadClient] Filename: $filename');

    try {
      // Get the models directory
      debugPrint('[ModelDownloadClient] Getting models directory...');
      final modelsDir = await getModelsDirectory();
      debugPrint('[ModelDownloadClient] Models dir: ${modelsDir.path}');
      final filePath = '${modelsDir.path}/$filename';
      final file = File(filePath);
      final tempPath = '$filePath.download';
      final tempFile = File(tempPath);

      // Check if file already exists
      if (file.existsSync()) {
        debugPrint(
            '[ModelDownloadClient] File already exists, returning: $filePath');
        return filePath;
      }

      // Check for partial download
      int startByte = 0;
      if (tempFile.existsSync()) {
        startByte = tempFile.lengthSync();
        debugPrint('[ModelDownloadClient] Resuming from byte: $startByte');
      }

      // Create request with range header for resume support
      debugPrint('[ModelDownloadClient] Creating HTTP request...');
      final request = http.Request('GET', Uri.parse(url));
      if (startByte > 0) {
        request.headers['Range'] = 'bytes=$startByte-';
      }

      debugPrint('[ModelDownloadClient] Sending request...');
      final response = await _httpClient.send(request);
      debugPrint(
          '[ModelDownloadClient] Response status: ${response.statusCode}');

      // Check for successful response
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw HttpException('Download failed: ${response.statusCode}');
      }

      // Get total size
      int totalBytes;
      if (response.statusCode == 206) {
        // Partial content - parse Content-Range header
        final contentRange = response.headers['content-range'];
        if (contentRange != null) {
          final match = RegExp(r'/(\d+)').firstMatch(contentRange);
          totalBytes = match != null ? int.parse(match.group(1)!) : 0;
        } else {
          totalBytes = startByte + response.contentLength!;
        }
      } else {
        totalBytes = response.contentLength ?? 0;
        startByte = 0; // Server doesn't support range, start over
        if (tempFile.existsSync()) {
          await tempFile.delete();
        }
      }

      // Open file for writing
      final sink = tempFile.openWrite(mode: FileMode.append);
      int bytesReceived = startByte;

      try {
        await for (final chunk in response.stream) {
          if (_isCancelled) {
            await sink.close();
            return null;
          }

          sink.add(chunk);
          bytesReceived += chunk.length;
          onProgress?.call(bytesReceived, totalBytes);
        }

        await sink.close();

        // Rename temp file to final filename
        await tempFile.rename(filePath);
        return filePath;
      } catch (e) {
        await sink.close();
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancels the current download.
  void cancelDownload() {
    _isCancelled = true;
  }

  /// Gets the models directory, creating it if needed.
  Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');

    if (!modelsDir.existsSync()) {
      modelsDir.createSync(recursive: true);
    }

    return modelsDir;
  }

  /// Lists all downloaded model files.
  Future<List<File>> listDownloadedModels() async {
    final modelsDir = await getModelsDirectory();

    if (!modelsDir.existsSync()) {
      return [];
    }

    final files = await modelsDir.list().toList();
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.gguf'))
        .toList();
  }

  /// Deletes a downloaded model file.
  Future<bool> deleteModel(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// Gets the file size of a downloaded model.
  Future<int?> getModelSize(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      return await file.length();
    }
    return null;
  }

  /// Checks if a model file exists.
  Future<bool> modelExists(String filename) async {
    final modelsDir = await getModelsDirectory();
    final file = File('${modelsDir.path}/$filename');
    return file.existsSync();
  }

  /// Gets the full path for a model filename.
  Future<String> getModelPath(String filename) async {
    final modelsDir = await getModelsDirectory();
    return '${modelsDir.path}/$filename';
  }

  /// Cleans up incomplete downloads.
  Future<void> cleanupPartialDownloads() async {
    final modelsDir = await getModelsDirectory();
    if (!modelsDir.existsSync()) return;

    final files = await modelsDir.list().toList();
    for (final file in files) {
      if (file is File && file.path.endsWith('.download')) {
        await file.delete();
      }
    }
  }
}
