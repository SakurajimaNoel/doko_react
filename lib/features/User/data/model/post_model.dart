// this class is used for response when fetching posts for individual profile information
import 'package:doko_react/features/User/data/model/user_model.dart';

class ProfilePostModel {
  final String id;
  final List<String> content;
  final String caption;
  final DateTime createdOn;

  const ProfilePostModel({
    required this.content,
    required this.caption,
    required this.createdOn,
    required this.id,
  });

  static ProfilePostModel createModel({required Map map}) {
    return ProfilePostModel(
      content: (map["content"] as List)
          .map((element) => element.toString())
          .toList(),
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
    );
  }
}

// used when fetching posts to show in user feed
class PostModel extends ProfilePostModel {
  final UserModel createdBy;

  const PostModel({
    required this.createdBy,
    required super.content,
    required super.caption,
    required super.createdOn,
    required super.id,
  });

  static PostModel createModel({required Map map}) {
    return PostModel(
      content: (map["content"] as List)
          .map((element) => element.toString())
          .toList(),
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
      createdBy: UserModel.createModel(map: map["createdBy"]),
    );
  }
}
