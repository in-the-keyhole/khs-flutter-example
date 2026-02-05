import 'package:flutter/material.dart';

/// A centered message displayed when there is no content to show.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.testId,
  });

  final String message;
  final IconData? icon;

  /// Optional test ID for widget testing and analytics.
  final String? testId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: testId,
      label: message,
      child: Center(
        key: testId != null ? ValueKey(testId) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
