import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

typedef GraphKeyGenerator = String Function(String);

enum DokiNodeType {
  user(
    nodeType: NodeType.user,
    keyGenerator: generateUserNodeKey,
    nodeName: "User",
    messageSubject: MessageSubject.dokiUser,
  ),

  post(
    nodeType: NodeType.post,
    keyGenerator: generatePostNodeKey,
    nodeName: "Post",
    messageSubject: MessageSubject.dokiPost,
  ),

  comment(
    nodeType: NodeType.comment,
    keyGenerator: generateCommentNodeKey,
    nodeName: "Comment",
    messageSubject: MessageSubject.text,
  ),

  discussion(
    nodeType: NodeType.discussion,
    keyGenerator: generateDiscussionNodeKey,
    nodeName: "Discussion",
    messageSubject: MessageSubject.dokiDiscussion,
  ),

  poll(
    nodeType: NodeType.poll,
    keyGenerator: generatePollNodeKey,
    nodeName: "Poll",
    messageSubject: MessageSubject.dokiPolls,
  );

  const DokiNodeType({
    required this.nodeType,
    required this.keyGenerator,
    required this.nodeName,
    required this.messageSubject,
  });

  final NodeType nodeType;
  final GraphKeyGenerator keyGenerator;
  final String nodeName;
  final MessageSubject messageSubject;

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
