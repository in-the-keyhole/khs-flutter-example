import 'package:flutter/material.dart';

import '../atoms/section_heading.dart';

/// Reusable section organism that displays a heading and content.
///
/// Combines a section heading with any child widgets.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.heading,
    required this.children,
    this.semanticsId,
  });

  final String heading;
  final List<Widget> children;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      label: 'Section: $heading',
      child: Column(
        key: semanticsId != null ? ValueKey<String>(semanticsId!) : null,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            heading,
            semanticsId:
                semanticsId != null ? '$semanticsId.heading' : null,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
