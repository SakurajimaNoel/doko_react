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
    required this.isPost,
    required this.cursor,
  });

  final String nodeId;
  final String username;
  final String cursor;
  final bool isPost;

  @override
  String toString() {
    return "NodeID: $nodeId \n Username: $username \n Cursor: $cursor \n IsPost: $isPost";
  }
}
