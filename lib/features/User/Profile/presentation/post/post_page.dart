import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/comment_input.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/post_widget.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final PostModel? post;
  final String postId;

  const PostPage({
    super.key,
    required this.post,
    required this.postId,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PostModel? post;
  late final UserProvider userProvider;
  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  bool loading = true;
  String error = "";

  @override
  void initState() {
    super.initState();

    post = widget.post;
    userProvider = context.read<UserProvider>();

    if (post == null) {
      fetchPostById();
    } else {
      fetchPostCommentsById();
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchPostById() async {
    var response =
        await userGraphqlService.getPostsById(widget.postId, userProvider.id);
    setState(() {
      loading = false;
    });

    if (response.status == ResponseStatus.error) return;

    setState(() {
      post = response.postInfo;
    });

    safePrint("printing user id");
    safePrint(post?.createdBy.id);
  }

  Future<void> fetchPostCommentsById() async {}

  void handlePostLike(bool value) {
    post?.updateUserLike(value);
  }

  void handlePostDisplayItem(int value) {
    post?.updatePostInitialItem(value);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Loader(),
      );
    }

    if (error.isNotEmpty || post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: ErrorText(
            Constants.errorMessage,
            fontSize: Constants.fontSize,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post!.caption),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: Constants.gap,
              ),
              children: [
                PostWidget(
                  post: post!,
                  handlePostLike: handlePostLike,
                  handlePostDisplayItem: handlePostDisplayItem,
                  location: PostLocation.page,
                ),
              ],
            ),
          ),
          const CommentInput()
        ],
      ),
    );
  }
}
