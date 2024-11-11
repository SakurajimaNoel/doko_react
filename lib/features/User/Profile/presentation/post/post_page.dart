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
  String? commentTargetId;
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
      commentTargetId = post!.id;
      fetchPostCommentsById();
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchPostById() async {
    var response = await userGraphqlService.getPostsById(
      widget.postId,
      username: userProvider.username,
    );
    setState(() {
      loading = false;
    });

    if (response.status == ResponseStatus.error) return;

    commentTargetId = response.postInfo?.id;
    setState(() {
      post = response.postInfo;
    });
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

    bool postComment = post!.id == commentTargetId!;
    final currTheme = Theme.of(context).colorScheme;

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
          Column(
            children: [
              if (!postComment)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                    vertical: Constants.padding * 0.5,
                  ),
                  color: currTheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text("Replying to someone comment"),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            commentTargetId = post!.id;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: Constants.width,
                        ),
                      ),
                    ],
                  ),
                ),
              CommentInput(
                createdBy: post!.createdBy.id,
                postId: post!.id,
                commentTargetId: commentTargetId!,
                successAction: () {
                  setState(() {
                    commentTargetId = post!.id;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
