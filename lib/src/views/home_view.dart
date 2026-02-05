import 'package:flutter/material.dart';

import '../components/pages/generic_page.dart';
import '../components/templates/centered_template.dart';
import '../localization/app_localizations.dart';
import '../models/interfaces/control_interface.dart';

/// Home view displaying a greeting message.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.controls,
  });

  static const routeName = '/home';

  final ControlInterface controls;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return GenericPage(
      title: localizations.homeTitle,
      navigationController: controls.navigation,
      semanticsId: 'view.home',
      templateBuilder: (semanticsId, sections) => CenteredTemplate(
        semanticsId: semanticsId,
        sections: sections,
      ),
      sections: [
        Text(
          localizations.homeGreeting,
          key: const ValueKey('view.home.greeting.text'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
