import 'package:doko_react/core/data/cache.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/features/User/data/model/model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';

// individual item for user post
class Content {
  final MediaTypeValue mediaType;
  final String key;
  String signedURL;

  Content({
    required this.mediaType,
    required this.key,
    required this.signedURL,
  });

  static Future<Content> createContentObject(String key) async {
    MediaTypeValue mediaType = MediaType.getMediaType(key);
    String? signedURL;

    if (mediaType == MediaTypeValue.video) {
      signedURL = await Cache.getFileFromCache(key);
    }

    if (signedURL == null || signedURL.isEmpty) {
      signedURL = await StorageUtils.generatePreSignedURL(key);
    }

    return Content(
      mediaType: mediaType,
      key: key,
      signedURL: signedURL,
    );
  }

  Future<void> refresh() async {
    signedURL = await StorageUtils.generatePreSignedURL(key);
  }
}

// this class is used for response when fetching posts for individual profile information
class ProfilePostModel {
  final String id;
  final String caption;
  final DateTime createdOn;
  final List<Content> content;

  const ProfilePostModel({
    required this.caption,
    required this.createdOn,
    required this.id,
    required this.content,
  });

  static Future<ProfilePostModel> createModel({required Map map}) async {
    List<Future<Content>> contentFuture = (map["content"] as List)
        .map((element) => Content.createContentObject(
              element.toString(),
            ))
        .toList();

    List<Content> content = await Future.wait(contentFuture);

    return ProfilePostModel(
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
      content: content,
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
    required super.caption,
    required super.createdOn,
    required super.id,
    required super.content,
  });

  PostModel.fromProfilePost({
    required ProfilePostModel post,
    required this.createdBy,
  }) : super(
          caption: post.caption,
          createdOn: post.createdOn,
          id: post.id,
          content: post.content,
        );

  static Future<PostModel> createModel({required Map map}) async {
    Future<UserModel> createdByFuture =
        UserModel.createModel(map: map["createdBy"]);

    List<Future<Content>> postContentFuture = (map["content"] as List)
        .map((element) => Content.createContentObject(
              element.toString(),
            ))
        .toList();

    List results = await Future.wait([
      createdByFuture,
      ...postContentFuture,
    ]);

    UserModel createdBy = results[0] as UserModel;
    List<Content> content = results.sublist(1).cast<Content>();

    return PostModel(
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      id: map["id"],
      createdBy: createdBy,
      content: content,
    );
  }
}
