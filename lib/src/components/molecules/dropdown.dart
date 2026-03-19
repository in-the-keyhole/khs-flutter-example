import 'package:flutter/material.dart';

/// Reusable dropdown button molecule.
///
/// A generic dropdown that accepts any type of items and handles selection.
class Dropdown<T> extends StatelessWidget {
  const Dropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.semanticsIdentifier,
    this.semanticsLabel,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? semanticsIdentifier;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final dropdown = DropdownButton<T>(
      key: semanticsIdentifier != null ? ValueKey<String>(semanticsIdentifier!) : null,
      value: value,
      onChanged: onChanged,
      items: items,
    );

    if (semanticsIdentifier != null || semanticsLabel != null) {
      return Semantics(
        identifier: semanticsIdentifier,
        label: semanticsLabel,
        child: dropdown,
      );
    }

    return dropdown;
  }
}
