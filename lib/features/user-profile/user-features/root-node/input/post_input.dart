import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';

class GetNodeInput {
  const GetNodeInput({
    required this.nodeId,
    required this.username,
  });

  final String nodeId;
  final String username;
}

class GetCommentsInput {
  const GetCommentsInput({
    required this.nodeId,
    required this.username,
    required this.nodeType,
    required this.cursor,
  });

  final String nodeId;
  final String username;
  final String cursor;

  // node type for which we are fetching comments
  final DokiNodeType nodeType;

  @override
  String toString() {
    return "NodeID: $nodeId \n Username: $username \n Cursor: $cursor \n IsPost: $nodeType";
  }
}
