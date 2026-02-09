import '../../clients/download_llm_client.dart';
import '../../clients/local_filesystem_client.dart';
import '../../clients/local_fllama_client.dart';
import '../../clients/local_preferences_client.dart';

/// Interface that holds references to all initialized clients.
///
/// This is initialized in main.dart and injected into the app.
class ClientInterface {
  const ClientInterface({
    required this.preferences,
    required this.fllama,
    required this.filesystem,
    required this.modelDownload,
  });

  final LocalPreferencesClient preferences;
  final LocalFllamaClient fllama;
  final LocalFilesystemClient filesystem;
  final DownloadLlmClient modelDownload;
}
