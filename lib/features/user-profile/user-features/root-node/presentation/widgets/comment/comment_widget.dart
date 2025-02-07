import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/like-widget/like_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/root_node_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
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
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    final commentId = getCommentIdFromCommentKey(widget.commentKey);

    final width = MediaQuery.sizeOf(context).width - Constants.padding * 3;
    final height = width / Constants.commentContainer;

    if (!graph.containsKey(widget.commentKey)) {
      // send a req to fetch the post
      context.read<UserActionBloc>().add(UserActionGetCommentByIdEvent(
            username: username,
            commentId: commentId,
          ));
    }

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionCommentDataFetchedState &&
            state.commentId == commentId;
      },
      builder: (context, state) {
        bool isError =
            state is UserActionCommentDataFetchedState && !state.success;

        if (!graph.containsKey(widget.commentKey)) {
          return _CommentWrapper(
            isReply: widget.isReply,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxWidth,
                  child: Center(
                    child: isError
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: Constants.gap * 0.25,
                            children: [
                              const StyledText.error(
                                "Error loading comment.",
                                size: Constants.smallFontSize * 1.125,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  context
                                      .read<UserActionBloc>()
                                      .add(UserActionGetCommentByIdEvent(
                                        username: username,
                                        commentId: commentId,
                                      ));
                                },
                                label: const Text("Retry"),
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          )
                        : const SmallLoadingIndicator.small(),
                  ),
                );
              },
            ),
          );
        }

        final CommentEntity comment =
            graph.getValueByKey(widget.commentKey)! as CommentEntity;

        return _CommentWrapper(
          isReply: widget.isReply,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Constants.gap * 0.5,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final width = MediaQuery.sizeOf(context).width;
                bool shrink = min(constraints.maxWidth, width) < 275;
                bool superShrink = min(constraints.maxWidth, width) < 225;

                // double shrinkFactor = shrink ? 0.875 : 1;
                double baseFontSize = shrink
                    ? Constants.smallFontSize
                    : Constants.smallFontSize * 1.125;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserWidget.small(
                      userKey: comment.commentBy,
                      key: ValueKey(comment.id),
                      trim: 16,
                      baseFontSize: baseFontSize,
                    ),
                    if (superShrink)
                      const SizedBox.shrink()
                    else
                      Text(
                        displayDateDifference(
                          comment.createdOn,
                          small: shrink,
                        ),
                        style: const TextStyle(
                          fontSize: Constants.smallFontSize * 0.875,
                        ),
                      ),
                  ],
                );
              }),
              if (comment.media.bucketPath.isNotEmpty)
                Container(
                  alignment: AlignmentDirectional.topStart,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.radius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    cacheKey: comment.media.bucketPath,
                    fit: BoxFit.contain,
                    imageUrl: comment.media.accessURI,
                    placeholder: (context, url) => const Center(
                      child: SmallLoadingIndicator.small(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    filterQuality: FilterQuality.high,
                    memCacheHeight: height.toInt(),
                    width: double.infinity,
                    // height: height,
                  ),
                ),
              if (comment.content.isNotEmpty)
                _CommentContent(
                  content: comment.content,
                ),
              _CommentActions(
                commentId: commentId,
                isReply: widget.isReply,
                parentNodeId: widget.parentNodeId,
              ),
            ],
          ),
        );
      },
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

    // if (isReply) {
    //   return LayoutBuilder(
    //     builder: (context, constraints) {
    //       bool shrink = constraints.maxWidth < 275;
    //       double shrinkFactor = shrink ? 0.75 : 1;
    //
    //       return Container(
    //         margin: EdgeInsets.only(
    //           left: Constants.padding * shrinkFactor,
    //         ),
    //         padding: const EdgeInsets.only(
    //           top: Constants.padding * 0.75,
    //         ),
    //         child: child,
    //       );
    //     },
    //   );
    // }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius),
        color: currTheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: currTheme.shadow.withValues(
              alpha: 0.25,
            ),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isReply
              ? null
              : () {
                  // send to comment page
                },
          onLongPress: () {
            // share to chat message or report and delete options
            final postId = context.read<RootNodeCommentProvider>().rootNodeId;
            FocusManager.instance.primaryFocus?.unfocus();

            Share.share(
              context: context,
              subject: MessageSubject.dokiPost,
              nodeIdentifier: postId,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(
              Constants.padding * 0.75,
            ),
            child: child,
          ),
        ),
      ),
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
              fontWeight: FontWeight.bold,
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
          fontWeight: FontWeight.bold,
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

class _CommentActionsState extends State<_CommentActions> {
  final UserGraph graph = UserGraph();

  late final String commentId = widget.commentId;
  late final String commentKey = generateCommentNodeKey(commentId);
  late final String username =
      (context.read<UserBloc>().state as UserCompleteState).username;

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
                    LikeWidget(
                      onPress: () {
                        context
                            .read<UserActionBloc>()
                            .add(UserActionCommentLikeActionEvent(
                              commentId: comment.id,
                              userLike: !comment.userLike,
                              username: username,
                            ));
                      },
                      userLike: comment.userLike,
                      shrinkFactor: 0.85,
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
                      width: Constants.gap * 0.5,
                    ),
                    TextButton(
                      onPressed: () {
                        String targetId =
                            widget.isReply ? widget.parentNodeId : commentId;

                        String targetUsername =
                            getUsernameFromUserKey(comment.commentBy);

                        // if (widget.isReply) {
                        //   CommentEntity entity = graph.getValueByKey(
                        //           generateCommentNodeKey(targetId))!
                        //       as CommentEntity;
                        //   targetUsername =
                        //       getUsernameFromUserKey(entity.commentBy);
                        // }

                        context.read<RootNodeCommentProvider>()
                          ..updateCommentTarget(
                            targetId,
                            targetUsername,
                          )
                          ..focusNode.requestFocus();
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.padding * 0.875,
                          vertical: Constants.padding * 0.5,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: TextStyle(
                          color: currTheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: Constants.smallFontSize,
                        ),
                      ),
                      child: const Text(
                        "Reply",
                      ),
                    ),
                    const SizedBox(
                      width: Constants.gap * 0.25,
                    ),
                    TextButton(
                      onPressed: () {
                        // for now sharing post only
                        final rootNodeId =
                            context.read<RootNodeCommentProvider>().rootNodeId;

                        FocusManager.instance.primaryFocus?.unfocus();

                        Share.share(
                          context: context,
                          subject: MessageSubject.dokiPost,
                          nodeIdentifier: rootNodeId,
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.padding * 0.875,
                          vertical: Constants.padding * 0.5,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: TextStyle(
                          color: currTheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: Constants.smallFontSize,
                        ),
                      ),
                      child: const Text(
                        "Share",
                      ),
                    ),
                  ],
                ),
                if (!widget.isReply)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = MediaQuery.sizeOf(context).width;
                      bool shrink = width < 300;

                      if (shrink) return const SizedBox.shrink();

                      return Text(
                        "${displayNumberFormat(comment.commentsCount)} Repl${comment.commentsCount > 1 ? "ies" : "y"}",
                        style: TextStyle(
                          color: currTheme.onSurfaceVariant,
                          fontSize: Constants.smallFontSize * 0.9,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
        const Divider(
          height: Constants.gap * 0.5,
        ),
        // if (!widget.isReply)
        //   _CommentReplies(
        //     commentId: comment.id,
        //   ),
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
        return BlocBuilder<RootNodeBloc, RootNodeState>(
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
                                          .read<RootNodeBloc>()
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
                              padding: const EdgeInsets.symmetric(
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
                                ? const SmallLoadingIndicator.small()
                                : comment.showReplies
                                    ? const Text("View more replies")
                                    : const Text("View replies"),
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
