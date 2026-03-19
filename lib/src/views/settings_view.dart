import 'package:flutter/material.dart';

import '../clients/download_llm_client.dart';
import '../clients/local_filesystem_client.dart';
import '../components/molecules/dropdown.dart';
import '../components/organisms/section.dart';
import '../components/templates/padded_template.dart';
import '../controllers/llm_controller.dart';
import '../controllers/model_download_controller.dart';
import '../localization/app_localizations.dart';
import '../models/interfaces/control_interface.dart';
import '../services/user_preferences_service.dart';
import 'llm_models_view.dart';

/// Settings view for configuring theme, language, and model preferences.
class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.controls,
    required this.llmController,
    required this.modelDownloadController,
    required this.preferencesService,
    required this.filesystemClient,
    required this.modelDownloadClient,
  });

  static const routeName = '/settings';

  final ControlInterface controls;
  final LlmController llmController;
  final ModelDownloadController modelDownloadController;
  final UserPreferencesService preferencesService;
  final LocalFilesystemClient filesystemClient;
  final DownloadLlmClient modelDownloadClient;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _systemPromptController;

  @override
  void initState() {
    super.initState();
    _systemPromptController = TextEditingController(
      text: widget.preferencesService.systemPrompt,
    );
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }

  void _saveSystemPrompt() {
    final text = _systemPromptController.text.trim();
    if (text.isNotEmpty) {
      widget.preferencesService.updateSystemPrompt(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeMode = widget.controls.theme.mode;
    final updateThemeMode = widget.controls.theme.updateMode;
    final locale = widget.controls.locale.locale;
    final updateLocale = widget.controls.locale.updateLocale;

    return Semantics(
      identifier: 'view.settings',
      label: 'Page',
      child: Scaffold(
        key: const ValueKey('view.settings'),
        appBar: AppBar(
          key: const ValueKey('view.settings.appBar'),
          title: Text(localizations.settingsTitle),
        ),
        body: ColumnTemplate(
          semanticsId: 'view.settings.template',
          sections: [
        Section(
          heading: localizations.modelHeading,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.modelDownloadController,
                widget.llmController,
              ]),
              builder: (context, _) {
                final downloaded =
                    widget.modelDownloadController.downloadedModels;
                final currentModelPath = widget.llmController.modelName;

                // Find the localPath of the currently loaded model
                String? currentValue;
                for (final item in downloaded) {
                  if (item.model.name == currentModelPath) {
                    currentValue = item.localPath;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (downloaded.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          localizations.modelNone,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      Dropdown<String?>(
                        value: currentValue,
                        onChanged: (path) {
                          if (path == null) return;
                          final item = downloaded.firstWhere(
                            (i) => i.localPath == path,
                          );
                          widget.llmController.loadModel(
                            path,
                            modelName: item.model.name,
                          );
                        },
                        semanticsIdentifier: 'view.settings.modelDropdown',
                        semanticsLabel: 'Model selection',
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(localizations.modelNone),
                          ),
                          for (final item in downloaded)
                            DropdownMenuItem<String?>(
                              value: item.localPath,
                              child: Text(item.model.name),
                            ),
                        ],
                      ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => LlmModelsView(
                              llmController: widget.llmController,
                              filesystemClient: widget.filesystemClient,
                              modelDownloadClient: widget.modelDownloadClient,
                              modelDownloadController:
                                  widget.modelDownloadController,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: Text(localizations.modelManage),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        Section(
          heading: localizations.contextSizeHeading,
          children: [
            Dropdown<int>(
              value: widget.preferencesService.contextSize,
              onChanged: (size) {
                if (size == null) return;
                widget.preferencesService.updateContextSize(size);
                setState(() {});
                // Reload model with new context size if one is loaded
                if (widget.llmController.isReady) {
                  final modelName = widget.llmController.modelName;
                  final downloaded =
                      widget.modelDownloadController.downloadedModels;
                  for (final item in downloaded) {
                    if (item.model.name == modelName &&
                        item.localPath != null) {
                      widget.llmController.loadModel(
                        item.localPath!,
                        modelName: modelName,
                        nCtx: size,
                      );
                      break;
                    }
                  }
                }
              },
              semanticsIdentifier: 'view.settings.contextSizeDropdown',
              semanticsLabel: 'Context size selection',
              items: const [
                DropdownMenuItem(value: 512, child: Text('512')),
                DropdownMenuItem(value: 1024, child: Text('1024')),
                DropdownMenuItem(value: 2048, child: Text('2048')),
                DropdownMenuItem(value: 4096, child: Text('4096')),
                DropdownMenuItem(value: 8192, child: Text('8192')),
              ],
            ),
          ],
        ),
        Section(
          heading: localizations.systemPromptHeading,
          children: [
            TextField(
              controller: _systemPromptController,
              decoration: InputDecoration(
                hintText: localizations.systemPromptHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onEditingComplete: _saveSystemPrompt,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                _saveSystemPrompt();
              },
            ),
          ],
        ),
        Section(
          heading: localizations.themeHeading,
          children: [
            Dropdown<ThemeMode>(
              value: themeMode,
              onChanged: updateThemeMode,
              semanticsIdentifier: 'view.settings.themeDropdown',
              semanticsLabel: 'Theme selection',
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(localizations.themeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(localizations.themeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(localizations.themeDark),
                ),
              ],
            ),
          ],
        ),
        Section(
          heading: localizations.languageHeading,
          children: [
            Dropdown<Locale?>(
              value: locale,
              onChanged: updateLocale,
              semanticsIdentifier: 'view.settings.languageDropdown',
              semanticsLabel: 'Language selection',
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(localizations.languageSystem),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(localizations.languageEnglish),
                ),
                DropdownMenuItem(
                  value: const Locale('es'),
                  child: Text(localizations.languageSpanish),
                ),
              ],
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
