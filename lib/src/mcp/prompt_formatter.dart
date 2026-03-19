/// Formats chat messages into ChatML prompt format for llama-cli.
///
/// ChatML uses special tokens to delimit roles and messages:
/// ```
/// <|im_start|>system
/// You are a helpful assistant.<|im_end|>
/// <|im_start|>user
/// Hello<|im_end|>
/// <|im_start|>assistant
/// ```
class PromptFormatter {
  PromptFormatter._();

  /// Formats a list of messages into a ChatML prompt string.
  ///
  /// Each message must have a `role` (system, user, assistant) and `content`.
  /// The prompt ends with `<|im_start|>assistant\n` to trigger generation.
  static String formatChatML(List<Map<String, String>> messages) {
    final buffer = StringBuffer();

    for (final message in messages) {
      final role = message['role'] ?? 'user';
      final content = message['content'] ?? '';
      buffer.writeln('<|im_start|>$role');
      buffer.writeln('$content<|im_end|>');
    }

    // Prompt the model to generate an assistant response
    buffer.write('<|im_start|>assistant\n');

    return buffer.toString();
  }

  /// Parses llama-cli output to extract the generated response.
  ///
  /// Strips any trailing EOS tokens and whitespace.
  static String parseResponse(String rawOutput) {
    var response = rawOutput;

    // Strip common EOS tokens that may appear in output
    const eosTokens = [
      '<|im_end|>',
      '</s>',
      '<|endoftext|>',
      '<|eot_id|>',
    ];

    for (final token in eosTokens) {
      final index = response.indexOf(token);
      if (index != -1) {
        response = response.substring(0, index);
      }
    }

    return response.trim();
  }
}
