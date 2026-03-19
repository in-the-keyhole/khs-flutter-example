import 'package:flutter/material.dart';

import '../../models/model_registry.dart';
import '../../models/objects/model_browser_item.dart';

export '../../models/objects/model_browser_item.dart';

/// A browsable list of available models for download.
///
/// Displays model information and allows downloading/selecting models.
class ModelBrowser extends StatelessWidget {
  const ModelBrowser({
    super.key,
    required this.items,
    required this.onDownload,
    required this.onSelect,
    this.onCancel,
    this.onDelete,
    this.semanticsId,
  });

  final List<ModelBrowserItem> items;
  final void Function(ModelInfo model) onDownload;
  final void Function(ModelInfo model, String path) onSelect;
  final void Function(ModelInfo model)? onCancel;
  final void Function(ModelInfo model, String path)? onDelete;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      label: 'Model browser',
      child: ListView.builder(
        key: semanticsId != null ? ValueKey<String>(semanticsId!) : null,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _ModelCard(
            item: item,
            onDownload: () => onDownload(item.model),
            onSelect: item.localPath != null
                ? () => onSelect(item.model, item.localPath!)
                : null,
            onCancel: onCancel != null ? () => onCancel!(item.model) : null,
            onDelete: onDelete != null && item.localPath != null
                ? () => onDelete!(item.model, item.localPath!)
                : null,
            semanticsId: semanticsId != null
                ? '$semanticsId.item.$index'
                : null,
          );
        },
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.item,
    required this.onDownload,
    this.onSelect,
    this.onCancel,
    this.onDelete,
    this.semanticsId,
  });

  final ModelBrowserItem item;
  final VoidCallback onDownload;
  final VoidCallback? onSelect;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final model = item.model;

    return Semantics(
      identifier: semanticsId,
      label: 'Model: ${model.name}',
      child: Card(
        key: semanticsId != null ? ValueKey<String>(semanticsId!) : null,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                model.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (model.recommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Recommended',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${model.parameters ?? "Unknown"} • ${model.quantization} • ${model.sizeString}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIcon(colorScheme),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                model.description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar (if downloading)
              if (item.status == ModelDownloadStatus.downloading) ...[
                LinearProgressIndicator(
                  value: item.downloadProgress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(item.downloadProgress * 100).toInt()}% downloaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActions(colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    switch (item.status) {
      case ModelDownloadStatus.notDownloaded:
        return Icon(Icons.cloud_download, color: colorScheme.onSurfaceVariant);
      case ModelDownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: item.downloadProgress,
            color: colorScheme.primary,
          ),
        );
      case ModelDownloadStatus.downloaded:
        return Icon(Icons.check_circle, color: colorScheme.primary);
    }
  }

  List<Widget> _buildActions(ColorScheme colorScheme) {
    switch (item.status) {
      case ModelDownloadStatus.notDownloaded:
        return [
          FilledButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download'),
          ),
        ];
      case ModelDownloadStatus.downloading:
        return [
          if (onCancel != null)
            OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
        ];
      case ModelDownloadStatus.downloaded:
        return [
          if (onDelete != null)
            TextButton(
              onPressed: onDelete,
              child: Text(
                'Delete',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Use'),
          ),
        ];
    }
  }
}
