import 'package:doko_react/core/global/entity/page-info/nodes.dart';

/// base class to use with user graph
abstract class GraphEntity {}

/// base class for nodes that allow comments in it
abstract class NodeWithCommentEntity implements GraphEntity {
  Nodes get comments;

  int get commentsCount;

  void updateCommentsCount(int count);
}

abstract class NodeWithMediaItems implements NodeWithCommentEntity {
  int get currDisplay;

  void updateDisplayItem(int item);
}
