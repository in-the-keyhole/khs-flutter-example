import 'package:flutter/material.dart';

/// A reusable confirmation dialog with customizable title, content, and actions.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
    this.testId,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  /// Optional callback when confirm button is pressed.
  /// If not provided, Navigator.pop(true) is called.
  final VoidCallback? onConfirm;

  /// Optional callback when cancel button is pressed.
  /// If not provided, Navigator.pop(false) is called.
  final VoidCallback? onCancel;

  /// Optional test ID for widget testing and analytics.
  final String? testId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: testId,
      label: 'Confirmation: $title',
      child: AlertDialog(
        key: testId != null ? ValueKey(testId) : null,
        title: Text(title),
        content: Text(content),
        actions: [
          Semantics(
            identifier: testId != null ? '$testId.cancelButton' : null,
            button: true,
            child: TextButton(
              key: testId != null ? ValueKey('$testId.cancelButton') : null,
              onPressed: () {
                if (onCancel != null) {
                  onCancel!();
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: Text(cancelText),
            ),
          ),
          Semantics(
            identifier: testId != null ? '$testId.confirmButton' : null,
            button: true,
            child: TextButton(
              key: testId != null ? ValueKey('$testId.confirmButton') : null,
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm!();
                } else {
                  Navigator.of(context).pop(true);
                }
              },
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(confirmText),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the confirmation dialog and returns the user's choice.
  ///
  /// If [onConfirm] and [onCancel] are provided, they will be called
  /// instead of closing the dialog. Otherwise, the dialog will close
  /// and return true for confirm, false for cancel.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? testId,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
        onCancel: onCancel,
        testId: testId,
      ),
    );
    return result ?? false;
  }
}
