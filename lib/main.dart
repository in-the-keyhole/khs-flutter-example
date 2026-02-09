import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/clients/download_llm_client.dart';
import 'src/clients/local_filesystem_client.dart';
import 'src/clients/local_fllama_client.dart';
import 'src/clients/local_preferences_client.dart';
import 'src/models/interfaces/client_interface.dart';

void main() async {
  // Ensure Flutter binding is initialized before using async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all clients
  final localPreferencesClient = LocalPreferencesClient();
  final localFllamaClient = LocalFllamaClient();
  final localFilesystemClient = LocalFilesystemClient();
  final modelDownloadClient = DownloadLlmClient();

  // Wrap clients in interface for dependency injection
  final clients = ClientInterface(
    preferences: localPreferencesClient,
    fllama: localFllamaClient,
    filesystem: localFilesystemClient,
    modelDownload: modelDownloadClient,
  );

  // Run the app with injected client interface
  runApp(MyApp(clients: clients));
}
