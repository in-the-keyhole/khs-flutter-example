import 'package:flutter/material.dart';

/// Status indicator molecule for LLM model state.
///
/// Shows loading progress, ready state, or error state for the model.
enum ModelState { notLoaded, loading, ready, error }

class ModelStatus extends StatelessWidget {
  const ModelStatus({
    super.key,
    required this.state,
    this.progress = 0.0,
    this.modelName,
    this.errorMessage,
    this.onLoadModel,
    this.semanticsId,
  });

  final ModelState state;
  final double progress;
  final String? modelName;
  final String? errorMessage;
  final VoidCallback? onLoadModel;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      identifier: semanticsId,
      label: 'Model status',
      child: Container(
        key: semanticsId != null ? ValueKey(semanticsId) : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(colorScheme),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildContent(context, colorScheme),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (state) {
      case ModelState.notLoaded:
        return colorScheme.surfaceContainerHighest;
      case ModelState.loading:
        return colorScheme.primaryContainer.withValues(alpha: 0.3);
      case ModelState.ready:
        return colorScheme.primaryContainer.withValues(alpha: 0.5);
      case ModelState.error:
        return colorScheme.errorContainer;
    }
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    switch (state) {
      case ModelState.notLoaded:
        return Row(
          children: [
            Icon(Icons.downloading, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No model loaded',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (onLoadModel != null)
              TextButton(
                onPressed: onLoadModel,
                child: const Text('Load'),
              ),
          ],
        );

      case ModelState.loading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Loading model...',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        );

      case ModelState.ready:
        return Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Model ready',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (modelName != null)
                    Text(
                      modelName!,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      case ModelState.error:
        return Row(
          children: [
            Icon(Icons.error, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error loading model',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (onLoadModel != null)
              TextButton(
                onPressed: onLoadModel,
                child: const Text('Retry'),
              ),
          ],
        );
    }
  }
}
