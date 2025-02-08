import 'package:doko_react/core/global/entity/page-info/nodes.dart';

/// base class to use with user graph
abstract class GraphEntity {}

abstract class NodeWithCommentEntity implements GraphEntity {
  Nodes get nodeComments;
}
