import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

typedef GraphKeyGenerator = String Function(String);

enum DokiNodeType {
  user(
    nodeType: NodeType.user,
    keyGenerator: generateUserNodeKey,
    nodeName: "User",
  ),

  post(
    nodeType: NodeType.post,
    keyGenerator: generatePostNodeKey,
    nodeName: "Post",
  ),

  comment(
    nodeType: NodeType.comment,
    keyGenerator: generateCommentNodeKey,
    nodeName: "Comment",
  ),

  discussion(
    nodeType: NodeType.discussion,
    keyGenerator: generateDiscussionNodeKey,
    nodeName: "Discussion",
  );

  const DokiNodeType({
    required this.nodeType,
    required this.keyGenerator,
    required this.nodeName,
  });

  final NodeType nodeType;
  final GraphKeyGenerator keyGenerator;
  final String nodeName;

  factory DokiNodeType.fromNodeType(NodeType nodeType) {
    for (var node in DokiNodeType.values) {
      if (node.nodeType == nodeType) return node;
    }

    return DokiNodeType.user;
  }

  factory DokiNodeType.fromName(String name) {
    for (var node in DokiNodeType.values) {
      if (node.name == name) return node;
    }

    return DokiNodeType.user;
  }
}
