import 'package:flutter/material.dart';

/// Reusable template that centers content.
///
/// This template provides a centered layout for displaying widgets.
class CenteredTemplate extends StatelessWidget {
  const CenteredTemplate({
    super.key,
    required this.sections,
    this.semanticsId,
  });

  final List<Widget> sections;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      label: 'Centered template',
      child: Center(
        key: semanticsId != null ? ValueKey(semanticsId) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sections,
        ),
      ),
    );
  }
}
