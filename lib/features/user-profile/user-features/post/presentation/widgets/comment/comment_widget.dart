import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/bloc/post_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/provider/post_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.commentKey,
    required this.parentNodeId,
  }) : isReply = false;

  const CommentWidget.reply({
    super.key,
    required this.commentKey,
    required this.parentNodeId,
  }) : isReply = true;

  final String commentKey;
  final bool isReply;
  final String parentNodeId;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();

    final commentId = generateCommentIdFromCommentKey(widget.commentKey);

    final CommentEntity comment =
        graph.getValueByKey(widget.commentKey)! as CommentEntity;

    final width = MediaQuery.sizeOf(context).width - Constants.padding * 3;
    final height = width / Constants.commentContainer;

    return _CommentWrapper(
      isReply: widget.isReply,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              User.small(
                userKey: comment.commentBy,
                key: ValueKey(comment.id),
              ),
              Text(
                displayDateDifference(comment.createdOn),
                style: const TextStyle(
                  fontSize: Constants.smallFontSize * 0.9,
                ),
              ),
            ],
          ),
          if (comment.media.bucketPath.isNotEmpty) ...[
            SizedBox(
              height: Constants.gap * 0.5,
            ),
            Container(
              alignment: AlignmentDirectional.topStart,
              // height: height,
              child: CachedNetworkImage(
                cacheKey: comment.media.bucketPath,
                fit: BoxFit.contain,
                imageUrl: comment.media.accessURI,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                filterQuality: FilterQuality.high,
                memCacheHeight: height.toInt(),
                // height: height,
              ),
            )
          ],
          if (comment.content.isNotEmpty) ...[
            SizedBox(
              height: Constants.gap * 0.5,
            ),
            _CommentContent(
              content: comment.content,
            ),
          ],
          SizedBox(
            height: Constants.gap * 0.5,
          ),
          _CommentActions(
            commentId: commentId,
            isReply: widget.isReply,
            parentNodeId: widget.parentNodeId,
          ),
        ],
      ),
    );
  }
}

class _CommentWrapper extends StatelessWidget {
  const _CommentWrapper({
    required this.child,
    required this.isReply,
  });

  final Widget child;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (isReply) {
      return Container(
        margin: const EdgeInsets.only(
          left: Constants.padding,
        ),
        padding: EdgeInsets.only(
          top: Constants.padding * 0.75,
        ),
        child: child,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      padding: EdgeInsets.only(
        left: Constants.padding * 0.75,
        right: Constants.padding * 0.75,
        bottom: Constants.padding * 0.5,
        top: Constants.padding * 0.75,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius * 0.5),
        color: currTheme.surfaceContainer,
      ),
      child: child,
    );
  }
}

class _CommentContent extends StatefulWidget {
  const _CommentContent({required this.content});

  final List<String> content;

  @override
  State<_CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<_CommentContent> {
  late List<String> content = widget.content;
  late String stringContent = content.join("");

  bool viewMore = false;

  TextSpan buildComment() {
    final currTheme = Theme.of(context).colorScheme;
    final buttonText = viewMore ? "View less" : "View More";

    bool showButton =
        stringContent.length > Constants.commentContentDisplayLimit;

    // for view more
    int len = 0;
    List<TextSpan> children = [];

    for (int i = 0; i < content.length; i++) {
      String item = content[i];
      len += item.length;

      bool usernameCandidate =
          item.startsWith("@") && item.endsWith(Constants.zeroWidthSpace);
      String itemAsUsername =
          usernameCandidate ? getUsernameFromCommentInput(item) : item;

      if (usernameCandidate && validateUsername(itemAsUsername)) {
        // valid mention
        children.add(
          TextSpan(
            text: item,
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushNamed(
                  RouterConstants.userProfile,
                  pathParameters: {
                    "username": itemAsUsername,
                  },
                );
              },
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: item,
          ),
        );
      }

      if (!viewMore && len >= Constants.commentContentDisplayLimit) break;
    }

    if (showButton) {
      children.add(TextSpan(
        text: " $buttonText",
        style: TextStyle(
          color: currTheme.outline,
          fontWeight: FontWeight.w600,
          fontSize: Constants.smallFontSize,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            setState(() {
              viewMore = !viewMore;
            });
          },
      ));
    }

    return TextSpan(
      style: TextStyle(
        color: currTheme.onSurface,
        height: 1.5,
        wordSpacing: 1.5,
      ),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: buildComment(),
    );
  }
}

class _CommentActions extends StatefulWidget {
  const _CommentActions({
    required this.commentId,
    required this.isReply,
    required this.parentNodeId,
  });

  final String commentId;
  final bool isReply;
  final String parentNodeId;

  @override
  State<_CommentActions> createState() => _CommentActionsState();
}

class _CommentActionsState extends State<_CommentActions>
    with SingleTickerProviderStateMixin {
  final UserGraph graph = UserGraph();

  late final String commentId = widget.commentId;
  late final String commentKey = generateCommentNodeKey(commentId);
  late final String username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  late final AnimationController controller = AnimationController(
    duration: const Duration(
      milliseconds: 200,
    ),
    vsync: this,
    value: 1.0,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommentEntity comment =
        graph.getValueByKey(commentKey)! as CommentEntity;

    final currTheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        BlocBuilder<UserActionBloc, UserActionState>(
          buildWhen: (previousState, state) {
            return state is UserActionNodeActionState &&
                state.nodeId == commentId;
          },
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.25, end: 1.0).animate(
                        CurvedAnimation(
                          parent: controller,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (!comment.userLike) {
                            controller
                                .reverse()
                                .then((value) => controller.forward());
                          }

                          context
                              .read<UserActionBloc>()
                              .add(UserActionCommentLikeActionEvent(
                                commentId: comment.id,
                                userLike: !comment.userLike,
                                username: username,
                              ));
                        },
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.all(Constants.padding * 0.5),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        iconSize: Constants.iconButtonSize * 0.75,
                        icon: comment.userLike
                            ? Icon(
                                Icons.thumb_up,
                                color: currTheme.primary,
                              )
                            : Icon(
                                Icons.thumb_up_outlined,
                                color: currTheme.secondary,
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: Constants.gap * 0.125,
                    ),
                    Text(
                      displayNumberFormat(comment.likesCount),
                      style: TextStyle(
                        color: currTheme.onSurfaceVariant,
                        fontSize: Constants.smallFontSize,
                      ),
                    ),
                    const SizedBox(
                      width: Constants.gap,
                    ),
                    TextButton(
                      onPressed: () {
                        String targetId =
                            widget.isReply ? widget.parentNodeId : commentId;

                        String targetUsername =
                            generateUsernameFromKey(comment.commentBy);

                        if (widget.isReply) {
                          CommentEntity entity = graph.getValueByKey(
                                  generateCommentNodeKey(targetId))!
                              as CommentEntity;
                          targetUsername =
                              generateUsernameFromKey(entity.commentBy);
                        }

                        context.read<PostCommentProvider>()
                          ..updateCommentTarget(
                            targetId,
                            targetUsername,
                          )
                          ..focusNode.requestFocus();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.padding,
                          vertical: Constants.padding * 0.5,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: TextStyle(
                          color: currTheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: Constants.smallFontSize,
                        ),
                      ),
                      child: Text(
                        "Reply",
                      ),
                    ),
                  ],
                ),
                // todo: for hierarchy show this
                if (!widget.isReply)
                  Text(
                    "${displayNumberFormat(comment.commentsCount)} Repl${comment.commentsCount > 1 ? "ies" : "y"}",
                    style: TextStyle(
                      color: currTheme.onSurfaceVariant,
                      fontSize: Constants.smallFontSize * 0.9,
                    ),
                  ),
              ],
            );
          },
        ),
        const Divider(
          height: Constants.gap * 0.5,
        ),
        // todo: for hierarchy show this
        if (!widget.isReply)
          _CommentReplies(
            commentId: comment.id,
          ),
      ],
    );
  }
}

class _CommentReplies extends StatefulWidget {
  const _CommentReplies({
    required this.commentId,
  });

  final String commentId;

  @override
  State<_CommentReplies> createState() => _CommentRepliesState();
}

class _CommentRepliesState extends State<_CommentReplies> {
  final UserGraph graph = UserGraph();

  late final String commentId = widget.commentId;
  late final String commentKey = generateCommentNodeKey(commentId);
  late final String username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final CommentEntity comment =
        graph.getValueByKey(commentKey)! as CommentEntity;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNewCommentState && state.nodeId == commentId;
      },
      builder: (context, state) {
        return BlocBuilder<PostBloc, PostState>(
          buildWhen: (previousState, state) {
            return (state is CommentReplyState &&
                    state.commentId == commentId) ||
                (state is LoadErrorState && state.nodeId == commentId);
          },
          builder: (context, state) {
            bool loading = state is CommentReplyLoadingState;
            bool loadError = state is LoadErrorState;

            return Column(
              children: [
                const SizedBox(
                  height: Constants.gap * 0.5,
                ),
                if (comment.showReplies &&
                    comment.comments.items.isNotEmpty) ...[
                  ...[
                    ...List.generate((comment.comments.items.length) * 2 - 1,
                        (index) {
                      if (index.isEven) {
                        int itemIndex = index ~/ 2;
                        return CommentWidget.reply(
                          commentKey: comment.comments.items[itemIndex],
                          parentNodeId: commentId,
                          key: ValueKey(comment.comments.items[itemIndex]),
                        );
                      } else {
                        return const SizedBox(
                          height: Constants.gap * 0.5,
                        );
                      }
                    })
                  ],
                ],
                if (comment.commentsCount > comment.comments.items.length)
                  Center(
                    child: loadError
                        ? StyledText.error(state.message)
                        : TextButton(
                            onPressed: loading
                                ? null
                                : () {
                                    if (comment.commentsCount < 1) return;

                                    if (!comment.showReplies) {
                                      setState(() {
                                        comment.showReplies = true;
                                      });
                                    }

                                    // fetch comment replies
                                    bool nextPage =
                                        comment.comments.pageInfo.hasNextPage;
                                    if (nextPage || comment.comments.isEmpty) {
                                      context
                                          .read<PostBloc>()
                                          .add(LoadCommentReplyEvent(
                                            details: GetCommentsInput(
                                              nodeId: commentId,
                                              username: username,
                                              isPost: false,
                                              cursor: nextPage
                                                  ? comment.comments.pageInfo
                                                      .endCursor!
                                                  : "",
                                            ),
                                          ));
                                    }
                                  },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: Constants.padding,
                                vertical: Constants.padding * 0.5,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textStyle: TextStyle(
                                color: currTheme.tertiary,
                                fontWeight: FontWeight.w500,
                                fontSize: Constants.smallFontSize,
                              ),
                            ),
                            child: loading
                                ? SmallLoadingIndicator.appBar()
                                : comment.showReplies
                                    ? Text("View more replies")
                                    : Text("View replies"),
                          ),
                  )
              ],
            );
          },
        );
      },
    );
  }
}
