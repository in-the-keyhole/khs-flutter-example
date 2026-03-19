import 'package:khs_flutter_example/src/mcp/list_models_tool.dart';
import 'package:khs_flutter_example/src/mcp/llm_chat_tool.dart';
import 'package:mcp_dart/mcp_dart.dart';

void main() {
  final server = MCPServer(name: 'local-llm', version: '1.0.0');

  server
    .tool(LlmChatTool())
    .tool(ListModelsTool());

  server.start(StdioTransport());
}
