import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

typedef GraphKeyGenerator = String Function(String);

enum DokiNodeType {
  user(
    nodeType: NodeType.user,
    keyGenerator: generateUserNodeKey,
  ),

  post(
    nodeType: NodeType.post,
    keyGenerator: generatePostNodeKey,
  ),

  comment(
    nodeType: NodeType.comment,
    keyGenerator: generateCommentNodeKey,
  ),

  discussion(
    nodeType: NodeType.discussion,
    keyGenerator: generateDiscussionNodeKey,
  );

  const DokiNodeType({
    required this.nodeType,
    required this.keyGenerator,
  });

  final NodeType nodeType;
  final GraphKeyGenerator keyGenerator;

  factory DokiNodeType.fromNodeType(NodeType nodeType) {
    for (var node in DokiNodeType.values) {
      if (node.nodeType == nodeType) return node;
    }

    return DokiNodeType.user;
  }
}
