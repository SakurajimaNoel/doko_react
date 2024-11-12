import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/Profile/widgets/comments/comment_widget.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/comment_input.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/post_widget.dart';
import 'package:doko_react/features/User/data/model/comment_model.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentTarget {
  final String targetId;
  final String targetUsername;

  const CommentTarget({
    required this.targetId,
    required this.targetUsername,
  });
}

class PostPage extends StatefulWidget {
  final PostModel? post;
  final String postId;

  const PostPage({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PostModel? post;
  CommentTarget? commentTarget;
  late final UserProvider userProvider;
  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  bool loading = false;
  String error = "";
  CommentInfo? commentInfo;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();

    post = widget.post;

    if (post == null) {
      fetchPostById();
    } else {
      setState(() {
        commentTarget = CommentTarget(
          targetId: post!.id,
          targetUsername: post!.createdBy.username,
        );
      });

      // fetch only comments
    }
  }

  Future<void> fetchPostById({
    bool setLoading = true,
  }) async {
    if (setLoading && !loading) {
      setState(() {
        loading = true;
      });
    }

    var response = await userGraphqlService.getPostsById(
      widget.postId,
      username: userProvider.username,
    );
    if (setLoading && loading) {
      setState(() {
        loading = false;
      });
    }

    if (response.status == ResponseStatus.error) return;

    setState(() {
      if (response.postInfo != null) {
        commentTarget = CommentTarget(
          targetId: response.postInfo!.id,
          targetUsername: response.postInfo!.createdBy.username,
        );
      }
      post = response.postInfo;
      commentInfo = response.commentInfo;
    });
  }

  void handlePostLike(bool value) {
    post?.updateUserLike(value);
  }

  void handlePostDisplayItem(int value) {
    post?.updatePostInitialItem(value);
  }

  Widget _buildItem(BuildContext context, int index, int itemCount) {
    if (index == 0) {
      return PostWidget(
        post: post!,
        handlePostLike: handlePostLike,
        handlePostDisplayItem: handlePostDisplayItem,
      );
    }

    if (index == itemCount - 1 || commentInfo == null) {
      return const Center(
        child: Text(
          "No more comments",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    CommentModel commentItem = commentInfo!.comments[index - 1];
    void likeCallback(bool like) {
      commentInfo!.comments[index - 1].updateUserLike(like);
    }

    void replyCallback() {
      setState(() {
        commentTarget = CommentTarget(
          targetId: commentItem.id,
          targetUsername: commentItem.commentBy.username,
        );
      });
    }

    return CommentWidget(
      comment: commentItem,
      handleCommentLike: likeCallback,
      handleReply: replyCallback,
    );
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

    bool commentReply = post!.id == commentTarget!.targetId;
    final currTheme = Theme.of(context).colorScheme;

    // one for post widget and one for comment show more
    int itemCount = commentInfo != null ? commentInfo!.comments.length + 2 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(post!.caption),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchPostById(
            setLoading: false,
          );
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  bottom: Constants.gap,
                ),
                itemBuilder: (BuildContext context, int index) =>
                    _buildItem(context, index, itemCount),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: Constants.gap * 2,
                  );
                },
                itemCount: itemCount,
              ),
            ),
            Column(
              children: [
                if (!commentReply)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                      vertical: Constants.padding * 0.5,
                    ),
                    color: currTheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              "Replying to ${commentTarget!.targetUsername} comment"),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              commentTarget = CommentTarget(
                                targetId: post!.id,
                                targetUsername: post!.createdBy.username,
                              );
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: Constants.width * 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                CommentInput(
                  key: ObjectKey(commentTarget),
                  createdBy: post!.createdBy.id,
                  postId: post!.id,
                  commentTargetId: commentTarget!.targetId,
                  successAction: () {
                    setState(() {
                      commentTarget = CommentTarget(
                        targetId: post!.id,
                        targetUsername: post!.createdBy.username,
                      );
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
