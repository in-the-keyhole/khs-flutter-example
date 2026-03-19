import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';

import '../models/model_registry.dart';

/// MCP tool that lists available LLM models from the registry.
class ListModelsTool extends ToolRunner {
  ListModelsTool()
      : super(
          name: 'list_models',
          description:
              'List available LLM models from the registry with download info.',
          inputSchema: const InputSchema(
            type: 'object',
            properties: {
              'recommended_only': {
                'type': 'boolean',
                'description':
                    'If true, only return recommended models. Default: false.',
              },
            },
          ),
        );

  @override
  Future<CallToolResult> execute(Map<String, dynamic> args) async {
    final recommendedOnly = args['recommended_only'] as bool? ?? false;

    final models = recommendedOnly
        ? ModelRegistry.recommendedModels
        : ModelRegistry.models;

    final modelsJson = models
        .map(
          (m) => {
            'id': m.id,
            'name': m.name,
            'description': m.description,
            'size': m.sizeString,
            'size_bytes': m.sizeBytes,
            'download_url': m.downloadUrl,
            'quantization': m.quantization,
            if (m.parameters != null) 'parameters': m.parameters,
            'recommended': m.recommended,
          },
        )
        .toList();

    return CallToolResult(
      content: [
        TextContent(
          text: const JsonEncoder.withIndent('  ').convert(modelsJson),
        ),
      ],
    );
  }
}
