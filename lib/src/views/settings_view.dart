import 'package:flutter/material.dart';

import '../components/molecules/dropdown.dart';
import '../components/organisms/section.dart';
import '../components/pages/generic_page.dart';
import '../localization/app_localizations.dart';
import '../models/interfaces/control_interface.dart';

/// Settings view for configuring theme and language preferences.
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.controls,
  });

  static const routeName = '/settings';

  final ControlInterface controls;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeMode = controls.theme.mode;
    final updateThemeMode = controls.theme.updateMode;
    final locale = controls.locale.locale;
    final updateLocale = controls.locale.updateLocale;

    return GenericPage(
      title: localizations.settingsTitle,
      navigationController: controls.navigation,
      semanticsId: 'view.settings',
      sections: [
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
    );
  }
}
