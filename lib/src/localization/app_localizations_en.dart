// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'khs_flutter_example';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeHeading => 'Theme';

  @override
  String get themeSystem => 'System Theme';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get navSettings => 'Settings';

  @override
  String get languageHeading => 'Language';

  @override
  String get languageSystem => 'System Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get navLlmChat => 'AI Chat';

  @override
  String get llmChatTitle => 'AI Chat';

  @override
  String get llmLoadModelTitle => 'Load Model';

  @override
  String get llmLoadModelDescription =>
      'Enter the path to a GGUF model file on your device.';

  @override
  String get llmModelPathLabel => 'Model Path';

  @override
  String get llmLoadButton => 'Load';

  @override
  String get llmStopGeneration => 'Stop';

  @override
  String get llmClearChat => 'Clear Chat';

  @override
  String get llmUnloadModel => 'Unload Model';

  @override
  String get llmStartChatting => 'Start chatting!';

  @override
  String get llmLoadModelFirst => 'Load a model to start chatting';

  @override
  String get llmInputHint => 'Type a message...';

  @override
  String get cancel => 'Cancel';

  @override
  String get llmBrowseModels => 'Browse Models';

  @override
  String get llmModelBrowserTitle => 'Available Models';

  @override
  String get llmDownloadModel => 'Download';

  @override
  String get llmUseModel => 'Use';

  @override
  String get llmDeleteModel => 'Delete';

  @override
  String get llmDownloading => 'Downloading...';

  @override
  String get llmDownloadComplete => 'Download complete';

  @override
  String get llmDownloadFailed => 'Download failed';

  @override
  String get llmPickFromDevice => 'Pick from device';

  @override
  String get llmPickFromDeviceSubtitle =>
      'Select a .gguf model file from your device';

  @override
  String get modelHeading => 'Model';

  @override
  String get modelManage => 'Manage Models';

  @override
  String get modelNone => 'None';

  @override
  String get contextSizeHeading => 'Context Size';

  @override
  String get systemPromptHeading => 'System Prompt';

  @override
  String get systemPromptHint => 'Enter system prompt...';

  @override
  String get conversationsTitle => 'Conversations';

  @override
  String get newChat => 'New Chat';

  @override
  String get renameConversation => 'Rename';

  @override
  String get deleteConversation => 'Delete';

  @override
  String get deleteConversationConfirm => 'Delete this conversation?';

  @override
  String get renameDialogTitle => 'Rename Conversation';

  @override
  String get save => 'Save';
}
