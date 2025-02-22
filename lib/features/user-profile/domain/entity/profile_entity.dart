import 'package:doko_react/core/global/entity/page-info/nodes.dart';

/// base class to use with user graph
abstract class GraphEntity {}

/// base class for nodes that allow user actions in it
abstract class GraphEntityWithUserAction implements GraphEntity {
  Nodes get comments;
  int get commentsCount;
  int get likesCount;
  bool get userLike;

  void updateCommentsCount(int count);
}

abstract class UserActionEntityWithMediaItems
    implements GraphEntityWithUserAction {
  int get currDisplay;

  void updateDisplayItem(int item);
}
