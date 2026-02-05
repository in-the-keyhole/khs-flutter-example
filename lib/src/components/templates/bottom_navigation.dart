import 'package:flutter/material.dart';

import '../../controllers/navigation_controller.dart';
import '../../localization/app_localizations.dart';

/// A template that provides a bottom navigation bar.
///
/// This template is designed to be used as the bottomNavigationBar
/// property of a Scaffold in page components.
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.navigationController,
    this.semanticsId,
  });

  final NavigationController navigationController;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Semantics(
      identifier: semanticsId ?? 'bottomNav',
      label: 'Bottom navigation bar',
      child: BottomNavigationBar(
        key: semanticsId != null
            ? ValueKey('$semanticsId.bar')
            : const ValueKey('bottomNav.bar'),
        currentIndex: navigationController.currentIndex,
        onTap: navigationController.navigateTo,
        items: [
          BottomNavigationBarItem(
            icon: Semantics(
              identifier: semanticsId != null
                  ? '$semanticsId.home.icon'
                  : 'bottomNav.home.icon',
              label: 'Home icon',
              child: const Icon(Icons.home),
            ),
            label: localizations.navHome,
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              identifier: semanticsId != null
                  ? '$semanticsId.llmChat.icon'
                  : 'bottomNav.llmChat.icon',
              label: 'AI Chat icon',
              child: const Icon(Icons.smart_toy),
            ),
            label: localizations.navLlmChat,
          ),
          BottomNavigationBarItem(
            icon: Semantics(
              identifier: semanticsId != null
                  ? '$semanticsId.settings.icon'
                  : 'bottomNav.settings.icon',
              label: 'Settings icon',
              child: const Icon(Icons.settings),
            ),
            label: localizations.navSettings,
          ),
        ],
      ),
    );
  }
}
