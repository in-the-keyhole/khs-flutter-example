import 'package:flutter_test/flutter_test.dart';
import 'package:khs_flutter_example/src/mcp/prompt_formatter.dart';

void main() {
  group('PromptFormatter', () {
    group('formatChatML', () {
      test('formats a single user message', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'user', 'content': 'Hello'},
        ]);

        expect(result, contains('<|im_start|>user'));
        expect(result, contains('Hello<|im_end|>'));
        expect(result, endsWith('<|im_start|>assistant\n'));
      });

      test('formats system + user messages', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'system', 'content': 'You are helpful.'},
          {'role': 'user', 'content': 'Hi'},
        ]);

        expect(result, contains('<|im_start|>system'));
        expect(result, contains('You are helpful.<|im_end|>'));
        expect(result, contains('<|im_start|>user'));
        expect(result, contains('Hi<|im_end|>'));
        expect(result, endsWith('<|im_start|>assistant\n'));
      });

      test('formats a full conversation', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'system', 'content': 'Be concise.'},
          {'role': 'user', 'content': 'What is 2+2?'},
          {'role': 'assistant', 'content': '4'},
          {'role': 'user', 'content': 'And 3+3?'},
        ]);

        expect(result, contains('<|im_start|>system'));
        expect(result, contains('<|im_start|>user'));
        expect(result, contains('<|im_start|>assistant'));
        expect(result, endsWith('<|im_start|>assistant\n'));
      });

      test('always ends with assistant prompt', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'user', 'content': 'Test'},
        ]);

        expect(result, endsWith('<|im_start|>assistant\n'));
      });

      test('handles empty messages list', () {
        final result = PromptFormatter.formatChatML([]);

        expect(result, equals('<|im_start|>assistant\n'));
      });

      test('preserves message content exactly', () {
        const content = 'Line 1\nLine 2\n  indented';
        final result = PromptFormatter.formatChatML([
          {'role': 'user', 'content': content},
        ]);

        expect(result, contains(content));
      });

      test('handles special characters in content', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'user', 'content': 'Hello <world> & "quotes"'},
        ]);

        expect(result, contains('Hello <world> & "quotes"'));
      });

      test('roles appear in correct order', () {
        final result = PromptFormatter.formatChatML([
          {'role': 'system', 'content': 'A'},
          {'role': 'user', 'content': 'B'},
          {'role': 'assistant', 'content': 'C'},
        ]);

        final systemIdx = result.indexOf('<|im_start|>system');
        final userIdx = result.indexOf('<|im_start|>user');
        final assistantIdx = result.indexOf('<|im_start|>assistant');

        expect(systemIdx, lessThan(userIdx));
        expect(userIdx, lessThan(assistantIdx));
      });
    });

    group('parseResponse', () {
      test('returns clean text unchanged', () {
        expect(PromptFormatter.parseResponse('Hello world'), equals('Hello world'));
      });

      test('strips im_end token', () {
        expect(
          PromptFormatter.parseResponse('Hello<|im_end|>'),
          equals('Hello'),
        );
      });

      test('strips </s> token', () {
        expect(
          PromptFormatter.parseResponse('Hello world</s>'),
          equals('Hello world'),
        );
      });

      test('strips <|endoftext|> token', () {
        expect(
          PromptFormatter.parseResponse('Answer<|endoftext|>'),
          equals('Answer'),
        );
      });

      test('strips <|eot_id|> token', () {
        expect(
          PromptFormatter.parseResponse('Answer<|eot_id|>'),
          equals('Answer'),
        );
      });

      test('trims surrounding whitespace', () {
        expect(
          PromptFormatter.parseResponse('  Hello world  '),
          equals('Hello world'),
        );
      });

      test('strips token and trims whitespace', () {
        expect(
          PromptFormatter.parseResponse('Hello world<|im_end|>  '),
          equals('Hello world'),
        );
      });

      test('handles empty string', () {
        expect(PromptFormatter.parseResponse(''), equals(''));
      });

      test('handles whitespace-only string', () {
        expect(PromptFormatter.parseResponse('   '), equals(''));
      });

      test('truncates at first EOS token', () {
        expect(
          PromptFormatter.parseResponse('First part<|im_end|>ignored'),
          equals('First part'),
        );
      });

      test('handles multiline response', () {
        const response = 'Line 1\nLine 2\nLine 3';
        expect(PromptFormatter.parseResponse(response), equals(response));
      });

      test('handles response with no EOS tokens', () {
        const response = 'A complete answer with no special tokens.';
        expect(PromptFormatter.parseResponse(response), equals(response));
      });
    });
  });
}
