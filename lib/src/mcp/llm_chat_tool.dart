import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

import 'prompt_formatter.dart';

/// MCP tool that sends chat messages to a local LLM via llama-cli.
class LlmChatTool extends ToolRunner {
  LlmChatTool()
      : super(
          name: 'chat',
          description:
              'Send chat messages to a local LLM and get a completion. '
              'Requires llama-cli (from llama.cpp) on PATH and a GGUF model file.',
          inputSchema: const InputSchema(
            type: 'object',
            properties: {
              'messages': {
                'type': 'array',
                'description': 'Conversation messages in chronological order.',
                'items': {
                  'type': 'object',
                  'properties': {
                    'role': {
                      'type': 'string',
                      'enum': ['system', 'user', 'assistant'],
                    },
                    'content': {'type': 'string'},
                  },
                  'required': ['role', 'content'],
                },
              },
              'model_path': {
                'type': 'string',
                'description':
                    'Path to a GGUF model file. Required on first call.',
              },
              'max_tokens': {
                'type': 'integer',
                'description': 'Maximum tokens to generate. Default: 512.',
              },
              'temperature': {
                'type': 'number',
                'description': 'Sampling temperature (0.0–2.0). Default: 0.7.',
              },
            },
            required: ['messages'],
          ),
        );

  String? _lastModelPath;

  @override
  Future<CallToolResult> execute(Map<String, dynamic> args) async {
    // Parse messages
    final rawMessages = args['messages'] as List<dynamic>? ?? [];
    if (rawMessages.isEmpty) {
      return _error('messages list is empty.');
    }

    final messages = rawMessages.map((m) {
      final map = m as Map<String, dynamic>;
      return {
        'role': (map['role'] as String?) ?? 'user',
        'content': (map['content'] as String?) ?? '',
      };
    }).toList();

    // Resolve model path (sticky across calls)
    final modelPath = (args['model_path'] as String?)?.trim().isNotEmpty == true
        ? args['model_path'] as String
        : _lastModelPath;

    if (modelPath == null) {
      return _error(
        'model_path is required on the first call. '
        'Provide the path to a GGUF model file.',
      );
    }
    _lastModelPath = modelPath;

    if (!File(modelPath).existsSync()) {
      return _error('model file not found at: $modelPath');
    }

    final maxTokens = (args['max_tokens'] as int?) ?? 512;
    final temperature = (args['temperature'] as num?)?.toDouble() ?? 0.7;

    // Locate llama-cli
    final llamaPath = await _findLlamaCli();
    if (llamaPath == null) {
      return _error(
        'llama-cli not found on PATH. '
        'Install llama.cpp: https://github.com/ggml-org/llama.cpp',
      );
    }

    // Format prompt and run
    final prompt = PromptFormatter.formatChatML(messages);

    try {
      final result = await Process.run(
        llamaPath,
        [
          '-m',
          modelPath,
          '-p',
          prompt,
          '--temp',
          temperature.toStringAsFixed(2),
          '-n',
          '$maxTokens',
          '--no-display-prompt',
          '-e',
        ],
        stdoutEncoding: const SystemEncoding(),
        stderrEncoding: const SystemEncoding(),
      );

      if (result.exitCode != 0) {
        final stderr = (result.stderr as String).trim();
        return _error('llama-cli exited ${result.exitCode}: $stderr');
      }

      final response = PromptFormatter.parseResponse(result.stdout as String);
      return CallToolResult(
        content: [
          TextContent(text: response.isEmpty ? '(empty response)' : response)
        ],
      );
    } on ProcessException catch (e) {
      return _error('failed to launch llama-cli: ${e.message}');
    }
  }
}

CallToolResult _error(String message) => CallToolResult(
      content: [TextContent(text: 'Error: $message')],
      isError: true,
    );

/// Searches for llama-cli on the system PATH.
Future<String?> _findLlamaCli() async {
  try {
    final result = await Process.run(
      Platform.isWindows ? 'where' : 'which',
      ['llama-cli'],
      stdoutEncoding: const SystemEncoding(),
    );
    if (result.exitCode == 0) {
      return (result.stdout as String).trim().split('\n').first.trim();
    }
  } on Exception catch (_) {
    // not found
  }
  return null;
}
