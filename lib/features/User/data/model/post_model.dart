

class PostModel {
  final String id;

  final List<String> content;
  final String caption;
  final DateTime createdOn;

  const PostModel({
    required this.content,
    required this.caption,
    required this.createdOn,
    required this.id,
  });

  static PostModel createModel({required Map map}) {
    return PostModel(
      content: (map["content"] as List)
          .map((element) => element.toString())
          .toList(),
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
    );
  }
}
