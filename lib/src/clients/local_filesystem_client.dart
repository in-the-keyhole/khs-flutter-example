import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// A client that handles local filesystem operations.
///
/// This client provides file picking and directory access functionality,
/// making it easier to mock for testing and swap implementations if needed.
class LocalFilesystemClient {
  LocalFilesystemClient({FilePicker? filePicker})
      : _filePicker = filePicker ?? FilePicker.platform;

  final FilePicker _filePicker;

  /// Opens a file picker dialog to select a single file.
  ///
  /// [allowedExtensions] optional list of allowed file extensions (without dots).
  /// [dialogTitle] optional title for the picker dialog.
  /// [initialDirectory] optional starting directory.
  ///
  /// Returns the selected file path, or null if cancelled.
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
    String? initialDirectory,
  }) async {
    final result = await _filePicker.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  /// Opens a file picker dialog to select multiple files.
  ///
  /// [allowedExtensions] optional list of allowed file extensions (without dots).
  /// [dialogTitle] optional title for the picker dialog.
  ///
  /// Returns a list of selected file paths, or empty list if cancelled.
  Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    final result = await _filePicker.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      dialogTitle: dialogTitle,
      allowMultiple: true,
    );

    if (result == null) return [];

    return result.files
        .where((file) => file.path != null)
        .map((file) => file.path!)
        .toList();
  }

  /// Opens a directory picker dialog.
  ///
  /// [dialogTitle] optional title for the picker dialog.
  /// [initialDirectory] optional starting directory.
  ///
  /// Returns the selected directory path, or null if cancelled.
  Future<String?> pickDirectory({
    String? dialogTitle,
    String? initialDirectory,
  }) async {
    return await _filePicker.getDirectoryPath(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
    );
  }

  /// Gets the application's documents directory.
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Gets the application's cache directory.
  Future<Directory> getCacheDirectory() async {
    return await getApplicationCacheDirectory();
  }

  /// Gets the application's support directory.
  Future<Directory> getSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// Gets the temporary directory.
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Checks if a file exists at the given path.
  bool fileExists(String path) {
    return File(path).existsSync();
  }

  /// Gets the file size in bytes.
  int? getFileSize(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return file.lengthSync();
    }
    return null;
  }

  /// Gets the filename from a path.
  String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  /// Clears the file picker cache (useful after picking files).
  Future<void> clearCache() async {
    await _filePicker.clearTemporaryFiles();
  }
}
