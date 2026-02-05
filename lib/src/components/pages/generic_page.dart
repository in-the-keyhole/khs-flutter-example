import 'package:flutter/material.dart';

import '../../controllers/navigation_controller.dart';
import '../templates/bottom_navigation.dart';
import '../templates/padded_template.dart';

/// A generic page layout with app bar, customizable body template, and bottom navigation.
///
/// By default uses [ColumnTemplate] for the body, but a custom template builder
/// can be provided to use a different layout (e.g., CenteredTemplate).
class GenericPage extends StatelessWidget {
  const GenericPage({
    super.key,
    required this.title,
    required this.sections,
    required this.navigationController,
    this.semanticsId,
    this.templateBuilder,
  });

  final String title;
  final List<Widget> sections;
  final NavigationController navigationController;
  final String? semanticsId;

  /// Optional template builder. If not provided, defaults to [ColumnTemplate].
  /// The builder receives the semanticsId and sections to wrap.
  final Widget Function(String? semanticsId, List<Widget> sections)? templateBuilder;

  @override
  Widget build(BuildContext context) {
    final body = templateBuilder != null
        ? templateBuilder!(
            semanticsId != null ? '$semanticsId.template' : null,
            sections,
          )
        : ColumnTemplate(
            semanticsId: semanticsId != null ? '$semanticsId.template' : null,
            sections: sections,
          );

    return Semantics(
      identifier: semanticsId,
      label: 'Page',
      child: Scaffold(
        key: semanticsId != null ? ValueKey(semanticsId) : null,
        appBar: AppBar(
          key: semanticsId != null ? ValueKey('$semanticsId.appBar') : null,
          title: Text(title),
        ),
        body: body,
        bottomNavigationBar: BottomNavigation(
          navigationController: navigationController,
          semanticsId: semanticsId != null ? '$semanticsId.bottomNav' : null,
        ),
      ),
    );
  }
}
