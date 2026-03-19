import 'package:flutter/material.dart';

/// A reusable section heading text widget.
///
/// Displays bold text with a standard font size for section headers.
class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.text, {
    super.key,
    this.semanticsId,
  });

  final String text;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      label: 'Heading: $text',
      header: true,
      child: Text(
        text,
        key: semanticsId != null ? ValueKey<String>(semanticsId!) : null,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
