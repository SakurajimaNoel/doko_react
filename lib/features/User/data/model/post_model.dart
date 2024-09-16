import 'package:doko_react/features/User/data/model/model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';

// this class is used for response when fetching posts for individual profile information
class ProfilePostModel {
  final String id;
  final List<String> content;
  final String caption;
  final DateTime createdOn;
  final List<String> signedContent;

  const ProfilePostModel({
    required this.content,
    required this.caption,
    required this.createdOn,
    required this.id,
    required this.signedContent,
  });

  static Future<ProfilePostModel> createModel({required Map map}) async {
    List<String> content =
        (map["content"] as List).map((element) => element.toString()).toList();

    List<String> signedContent =
        await StorageUtils.generatePreSignedURLs(content);
    return ProfilePostModel(
      content: content,
      signedContent: signedContent,
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
    );
  }
}

// user profile posts response
class ProfilePostInfo {
  List<ProfilePostModel> posts;
  final NodeInfo info;

  ProfilePostInfo({
    required this.posts,
    required this.info,
  });

  void addPosts(List<ProfilePostModel> newPosts) {
    posts.addAll(newPosts);
  }

  static Future<ProfilePostInfo> createModel({required Map map}) async {
    var postFutures = (map["edges"] as List)
        .map((post) => ProfilePostModel.createModel(map: post["node"]))
        .toList();

    List<ProfilePostModel> posts = await Future.wait(postFutures);

    return ProfilePostInfo(
      posts: posts,
      info: NodeInfo.createModel(
        map: map["pageInfo"],
      ),
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
    required super.signedContent,
  });

  PostModel.fromProfilePost({
    required ProfilePostModel post,
    required this.createdBy,
  }) : super(
          caption: post.caption,
          content: post.content,
          createdOn: post.createdOn,
          id: post.id,
          signedContent: post.signedContent,
        );

  static Future<PostModel> createModel({required Map map}) async {
    List<String> content =
        (map["content"] as List).map((element) => element.toString()).toList();

    List<String> signedContent =
        await StorageUtils.generatePreSignedURLs(content);

    UserModel createdBy = await UserModel.createModel(map: map["createdBy"]);

    return PostModel(
      content: content,
      signedContent: signedContent,
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
      createdBy: createdBy,
    );
  }
}
