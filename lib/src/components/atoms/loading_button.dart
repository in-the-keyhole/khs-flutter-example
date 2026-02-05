import 'package:flutter/material.dart';

/// A button that displays a loading indicator when processing.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.testId,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  /// Optional test ID for widget testing and analytics.
  final String? testId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: testId,
      button: true,
      enabled: !isLoading && onPressed != null,
      child: ElevatedButton(
        key: testId != null ? ValueKey(testId) : null,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : child,
      ),
    );
  }
}
