import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

typedef GraphKeyGenerator = String Function(String);
typedef GraphEntityGenerator = Future<GraphEntity> Function({required Map map});

enum DokiNodeType {
  user(
    nodeType: NodeType.user,
    keyGenerator: generateUserNodeKey,
    nodeName: "User",
    messageSubject: MessageSubject.dokiUser,
    entityGenerator: UserEntity.createEntity,
  ),

  post(
    nodeType: NodeType.post,
    keyGenerator: generatePostNodeKey,
    nodeName: "Post",
    messageSubject: MessageSubject.dokiPost,
    entityGenerator: PostEntity.createEntity,
  ),

  comment(
    nodeType: NodeType.comment,
    keyGenerator: generateCommentNodeKey,
    nodeName: "Comment",
    messageSubject: MessageSubject.text,
    entityGenerator: CommentEntity.createEntity,
  ),

  discussion(
    nodeType: NodeType.discussion,
    keyGenerator: generateDiscussionNodeKey,
    nodeName: "Discussion",
    messageSubject: MessageSubject.dokiDiscussion,
    entityGenerator: DiscussionEntity.createEntity,
  ),

  poll(
    nodeType: NodeType.poll,
    keyGenerator: generatePollNodeKey,
    nodeName: "Poll",
    messageSubject: MessageSubject.dokiPolls,
    entityGenerator: PollEntity.createEntity,
  );

  const DokiNodeType({
    required this.nodeType,
    required this.keyGenerator,
    required this.nodeName,
    required this.messageSubject,
    required this.entityGenerator,
  });

  final NodeType nodeType;
  final GraphKeyGenerator keyGenerator;
  final String nodeName;
  final MessageSubject messageSubject;
  final GraphEntityGenerator entityGenerator;

  factory DokiNodeType.fromNodeType(NodeType nodeType) {
    for (var node in DokiNodeType.values) {
      if (node.nodeType == nodeType) return node;
    }

    return DokiNodeType.user;
  }

  factory DokiNodeType.fromMessageSubject(MessageSubject subject) {
    for (var node in DokiNodeType.values) {
      if (node.messageSubject == subject) return node;
    }

    return DokiNodeType.comment;
  }

  factory DokiNodeType.fromName(String name) {
    for (var node in DokiNodeType.values) {
      if (node.name == name) return node;
    }

    return DokiNodeType.user;
  }

  /// get node type from typename
  factory DokiNodeType.fromTypename(String typename) {
    for (var node in DokiNodeType.values) {
      if (node.nodeName == typename) return node;
    }
    return DokiNodeType.user;
  }
}
