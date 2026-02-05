import 'package:flutter/material.dart';

/// Reusable template that displays widgets in a padded column.
///
/// This template provides a padded vertical layout for displaying sections.
class ColumnTemplate extends StatelessWidget {
  const ColumnTemplate({
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
      label: 'Column template',
      child: Padding(
        key: semanticsId != null ? ValueKey(semanticsId) : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections,
        ),
      ),
    );
  }
}
