class NodeInfo {
  String? endCursor;
  bool hasNextPage;

  NodeInfo({
    required this.endCursor,
    required this.hasNextPage,
  });

  void updateInfo(String endCursor, bool hasNextPage) {
    this.endCursor = endCursor;
    this.hasNextPage = hasNextPage;
  }

  static NodeInfo createModel({required Map map}) {
    return NodeInfo(
      endCursor: map["endCursor"],
      hasNextPage: map["hasNextPage"],
    );
  }
}
