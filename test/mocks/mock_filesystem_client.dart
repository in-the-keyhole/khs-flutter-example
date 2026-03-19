import 'package:file_picker/file_picker.dart';
import 'package:khs_flutter_example/src/clients/local_filesystem_client.dart';

/// Minimal no-op FilePicker so LocalFilesystemClient can be constructed
/// in test environments where the real platform plugin is not available.
class _StubFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    void Function(FilePickerStatus)? onFileLoading,
  }) async =>
      null;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async =>
      null;

  @override
  Future<bool?> clearTemporaryFiles() async => true;
}

/// Mock filesystem client for testing that extends the real class.
class MockFilesystemClient extends LocalFilesystemClient {
  MockFilesystemClient() : super(filePicker: _StubFilePicker());

  String? fileToReturn;

  @override
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
    String? initialDirectory,
  }) async =>
      fileToReturn;

  @override
  String getFileName(String path) => path.split('/').last;

  @override
  bool fileExists(String path) => false;
}
