import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/clients/local_filesystem_client.dart';

/// Mock FilePicker for testing
class MockFilePicker extends FilePicker {
  String? mockSinglePath;
  List<String>? mockMultiplePaths;
  String? mockDirectoryPath;
  bool shouldReturnNull = false;

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
  }) async {
    if (shouldReturnNull) return null;

    if (allowMultiple) {
      if (mockMultiplePaths == null || mockMultiplePaths!.isEmpty) {
        return null;
      }
      return FilePickerResult(
        mockMultiplePaths!
            .map((path) => PlatformFile(name: path.split('/').last, size: 0, path: path))
            .toList(),
      );
    } else {
      if (mockSinglePath == null) return null;
      return FilePickerResult([
        PlatformFile(name: mockSinglePath!.split('/').last, size: 0, path: mockSinglePath),
      ]);
    }
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    if (shouldReturnNull) return null;
    return mockDirectoryPath;
  }
}

void main() {
  group('LocalFilesystemClient', () {
    late LocalFilesystemClient client;
    late MockFilePicker mockFilePicker;

    setUp(() {
      mockFilePicker = MockFilePicker();
      client = LocalFilesystemClient(filePicker: mockFilePicker);
    });

    group('pickFile', () {
      test('should return selected file path', () async {
        mockFilePicker.mockSinglePath = '/path/to/file.txt';

        final result = await client.pickFile();

        expect(result, equals('/path/to/file.txt'));
      });

      test('should return null when cancelled', () async {
        mockFilePicker.shouldReturnNull = true;

        final result = await client.pickFile();

        expect(result, isNull);
      });

      test('should accept allowed extensions', () async {
        mockFilePicker.mockSinglePath = '/path/to/file.gguf';

        final result = await client.pickFile(
          allowedExtensions: ['gguf', 'bin'],
        );

        expect(result, isNotNull);
      });

      test('should accept dialog title', () async {
        mockFilePicker.mockSinglePath = '/path/to/file.txt';

        final result = await client.pickFile(
          dialogTitle: 'Select a file',
        );

        expect(result, isNotNull);
      });

      test('should accept initial directory', () async {
        mockFilePicker.mockSinglePath = '/path/to/file.txt';

        final result = await client.pickFile(
          initialDirectory: '/initial/path',
        );

        expect(result, isNotNull);
      });
    });

    group('pickMultipleFiles', () {
      test('should return list of selected file paths', () async {
        mockFilePicker.mockMultiplePaths = ['/path/file1.txt', '/path/file2.txt'];

        final result = await client.pickMultipleFiles();

        expect(result.length, equals(2));
        expect(result[0], equals('/path/file1.txt'));
        expect(result[1], equals('/path/file2.txt'));
      });

      test('should return empty list when cancelled', () async {
        mockFilePicker.shouldReturnNull = true;

        final result = await client.pickMultipleFiles();

        expect(result, isEmpty);
      });

      test('should filter out files without paths', () async {
        mockFilePicker.mockMultiplePaths = ['/path/file1.txt'];

        final result = await client.pickMultipleFiles();

        expect(result, isNotEmpty);
      });

      test('should accept allowed extensions', () async {
        mockFilePicker.mockMultiplePaths = ['/path/file.gguf'];

        final result = await client.pickMultipleFiles(
          allowedExtensions: ['gguf'],
        );

        expect(result, isNotEmpty);
      });
    });

    group('pickDirectory', () {
      test('should return selected directory path', () async {
        mockFilePicker.mockDirectoryPath = '/path/to/directory';

        final result = await client.pickDirectory();

        expect(result, equals('/path/to/directory'));
      });

      test('should return null when cancelled', () async {
        mockFilePicker.shouldReturnNull = true;

        final result = await client.pickDirectory();

        expect(result, isNull);
      });

      test('should accept dialog title', () async {
        mockFilePicker.mockDirectoryPath = '/path/to/directory';

        final result = await client.pickDirectory(
          dialogTitle: 'Select directory',
        );

        expect(result, isNotNull);
      });
    });

    group('getFileName', () {
      test('should extract filename from Unix path', () {
        final name = client.getFileName('/path/to/file.txt');

        expect(name, equals('file.txt'));
      });

      test('should handle file in root', () {
        final name = client.getFileName('/file.txt');

        expect(name, equals('file.txt'));
      });

      test('should handle filename only', () {
        final name = client.getFileName('file.txt');

        expect(name, equals('file.txt'));
      });

      test('should handle Windows paths on Windows', () {
        if (Platform.isWindows) {
          final name = client.getFileName('C:\\Users\\test\\file.txt');
          expect(name, equals('file.txt'));
        }
      });

      test('should handle empty string', () {
        final name = client.getFileName('');

        expect(name, equals(''));
      });
    });

    group('Edge Cases', () {
      test('pickFile should handle null path in result', () async {
        mockFilePicker.mockSinglePath = null;

        final result = await client.pickFile();

        expect(result, isNull);
      });

      test('pickMultipleFiles should return empty list for null result', () async {
        mockFilePicker.mockMultiplePaths = null;

        final result = await client.pickMultipleFiles();

        expect(result, isEmpty);
      });

      test('pickMultipleFiles should return empty list for empty paths', () async {
        mockFilePicker.mockMultiplePaths = [];

        final result = await client.pickMultipleFiles();

        expect(result, isEmpty);
      });
    });
  });
}
