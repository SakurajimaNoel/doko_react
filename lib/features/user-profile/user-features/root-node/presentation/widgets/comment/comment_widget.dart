import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/debounce/debounce.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/like-widget/like_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/markdown-display-widget/markdown_display_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.commentKey,
    required this.parentNodeId,
    this.isReplyPage = false,
  }) : isReply = false;

  const CommentWidget.reply({
    super.key,
    required this.commentKey,
    required this.parentNodeId,
  })  : isReply = true,
        isReplyPage = false;

  final String commentKey;
  final bool isReply;
  final String parentNodeId;

  /// used with comment reply page from notifications
  final bool isReplyPage;

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

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isCommentPage = currentRoute == RouterConstants.comment;

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
            commentId: commentId,
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
          commentId: commentId,
          isReply: widget.isReply,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Constants.gap * 0.5,
            children: [
              if (comment.replyOn != null && !widget.isReplyPage) ...[
                _CommentReplyPreview(
                  commentId: comment.replyOn!,
                ),
                const SizedBox(
                  height: Constants.gap * 0.125,
                ),
              ],
              LayoutBuilder(builder: (context, constraints) {
                final width = MediaQuery.sizeOf(context).width;
                bool shrink = min(constraints.maxWidth, width) < 275;
                bool superShrink = min(constraints.maxWidth, width) < 225;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!shrink && isCommentPage && !widget.isReply)
                      UserWidget(
                        userKey: comment.commentBy,
                        key: ValueKey(comment.id),
                      )
                    else
                      UserWidget.small(
                        userKey: comment.commentBy,
                        key: ValueKey("${comment.id}-shrink"),
                      ),
                    if (!superShrink)
                      Text(
                        displayDateDifference(
                          comment.createdOn,
                          format: shrink ? "d MMM y" : "EEE, d MMM y",
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
                isReplyPage: widget.isReplyPage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentReplyPreview extends StatelessWidget {
  const _CommentReplyPreview({
    required this.commentId,
  });

  final String commentId;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    final commentKey = generateCommentNodeKey(commentId);

    if (!graph.containsKey(commentKey)) {
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
        // bool isError =
        //     state is UserActionCommentDataFetchedState && !state.success;

        final comment = graph.getValueByKey(commentKey);

        String displayText = "";
        if (comment is CommentEntity) {
          if (comment.content.isEmpty) {
            displayText = "🖼️ Media";
          } else {
            displayText = trimText(
              comment.content.join(),
              len: 32,
            );
          }
        } else {
          displayText = "Comment loading...";
        }

        return Material(
          color: currTheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              if (comment is CommentEntity && comment.index != null) {
                int commentIndex = comment.index!;
                final observerController =
                    context.read<NodeCommentProvider>().controller;
                final userActionBloc = context.read<UserActionBloc>();

                if (observerController != null) {
                  // immediately send the event in case widget is already in view
                  userActionBloc.add(UserActionNodeHighlightEvent(
                    nodeId: comment.id,
                  ));
                  Timer(
                      const Duration(
                        milliseconds: Constants.maxScrollDuration,
                      ), () {
                    // fire highlight event
                    userActionBloc.add(UserActionNodeHighlightEvent(
                      nodeId: comment.id,
                    ));
                  });

                  observerController.animateTo(
                    index: commentIndex,
                    duration: const Duration(
                      milliseconds: Constants.maxScrollDuration,
                    ),
                    curve: Curves.fastOutSlowIn,
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                right: Constants.padding * 0.5,
              ),
              child: IntrinsicHeight(
                child: Row(
                  spacing: Constants.gap * 0.625,
                  children: [
                    VerticalDivider(
                      thickness: Constants.width * 0.375,
                      width: Constants.width * 0.375,
                      color: currTheme.inversePrimary,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Constants.padding * 0.5,
                        ),
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontSize: Constants.smallFontSize,
                            color: currTheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommentWrapper extends StatefulWidget {
  const _CommentWrapper({
    required this.child,
    required this.isReply,
    required this.commentId,
  });

  final Widget child;
  final bool isReply;
  final String commentId;

  @override
  State<_CommentWrapper> createState() => _CommentWrapperState();
}

class _CommentWrapperState extends State<_CommentWrapper> {
  bool highlight = false;
  final highlightDebounce = Debounce(
    const Duration(
      milliseconds: 1500,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isCommentPage = currentRoute == RouterConstants.comment;

    if (isCommentPage && !widget.isReply) {
      return Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: widget.child,
      );
    }

    return BlocListener<UserActionBloc, UserActionState>(
      listenWhen: (previousState, state) {
        return state is UserActionNodeHighlightState &&
            state.nodeId == widget.commentId;
      },
      listener: (context, state) {
        if (!highlight) {
          setState(() {
            highlight = true;
          });
        }
        highlightDebounce(() {
          if (highlight) {
            setState(() {
              highlight = false;
            });
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Constants.padding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Constants.radius),
          color: highlight
              ? currTheme.primaryContainer
              : currTheme.surfaceContainer,
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
            onTap: widget.isReply
                ? null
                : () {
                    // send to comment page
                    final nodeProvider = context.read<NodeCommentProvider>();

                    final rootNodeId = nodeProvider.rootNodeId;
                    final rootNodeType = nodeProvider.rootNodeType;
                    final rootNodeBy = nodeProvider.rootNodeCreatedBy;

                    context.pushNamed(
                      RouterConstants.comment,
                      pathParameters: {
                        "rootNodeType": rootNodeType.name,
                        "rootNodeId": rootNodeId,
                        "commentId": widget.commentId,
                        "userId": rootNodeBy,
                        "parentNodeType": rootNodeType.name,
                        "parentNodeId": rootNodeId,
                      },
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(
                Constants.padding * 0.75,
              ),
              child: widget.child,
            ),
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

  // TextSpan buildComment() {
  //   final currTheme = Theme.of(context).colorScheme;
  //   final buttonText = viewMore ? "View less" : "View More";
  //
  //   bool showButton =
  //       stringContent.length > Constants.commentContentDisplayLimit;
  //
  //   // for view more
  //   int len = 0;
  //   List<TextSpan> children = [];
  //
  //   for (int i = 0; i < content.length; i++) {
  //     String item = content[i];
  //     len += item.length;
  //
  //     bool usernameCandidate =
  //         item.startsWith("@") && item.endsWith(Constants.zeroWidthSpace);
  //     String itemAsUsername =
  //         usernameCandidate ? getUsernameFromCommentInput(item) : item;
  //
  //     if (usernameCandidate && validateUsername(itemAsUsername)) {
  //       // valid mention
  //       children.add(
  //         TextSpan(
  //           text: item,
  //           style: TextStyle(
  //             color: currTheme.primary,
  //             fontWeight: FontWeight.bold,
  //           ),
  //           recognizer: TapGestureRecognizer()
  //             ..onTap = () {
  //               context.pushNamed(
  //                 RouterConstants.userProfile,
  //                 pathParameters: {
  //                   "username": itemAsUsername,
  //                 },
  //               );
  //             },
  //         ),
  //       );
  //     } else {
  //       children.add(
  //         TextSpan(
  //           text: item,
  //         ),
  //       );
  //     }
  //
  //     if (!viewMore && len >= Constants.commentContentDisplayLimit) break;
  //   }
  //
  //   if (showButton) {
  //     children.add(TextSpan(
  //       text: " $buttonText",
  //       style: TextStyle(
  //         color: currTheme.outline,
  //         fontWeight: FontWeight.bold,
  //         fontSize: Constants.smallFontSize,
  //       ),
  //       recognizer: TapGestureRecognizer()
  //         ..onTap = () {
  //           setState(() {
  //             viewMore = !viewMore;
  //           });
  //         },
  //     ));
  //   }
  //
  //   return TextSpan(
  //     style: TextStyle(
  //       color: currTheme.onSurface,
  //       height: 1.5,
  //       wordSpacing: 1.5,
  //     ),
  //     children: children,
  //   );
  // }

  List<String> buildCommentContent() {
    final buttonText = viewMore ? "View less" : "View More";

    bool showButton =
        stringContent.length > Constants.commentContentDisplayLimit;

    // for view more
    int len = 0;
    List<String> children = [];

    for (int i = 0; i < content.length; i++) {
      String item = content[i];
      len += item.length;

      bool usernameCandidate =
          item.startsWith("@") && item.endsWith(Constants.zeroWidthSpace);
      String itemAsUsername =
          usernameCandidate ? getUsernameFromCommentInput(item) : item;

      if (usernameCandidate && validateUsername(itemAsUsername)) {
        // valid mention
        String mentionLink = "[$item](doki@user:$itemAsUsername)";
        children.add(mentionLink);
      } else {
        children.add(item);
      }

      if (!viewMore && len >= Constants.commentContentDisplayLimit) break;
    }

    String comment = children.join("");

    return [comment, showButton ? buttonText : ""];
  }

  @override
  Widget build(BuildContext context) {
    List<String> content = buildCommentContent();
    final currTheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: Constants.gap * 0.25,
      children: [
        MarkdownDisplayWidget(
          data: content.first,
        ),
        if (content.last.isNotEmpty)
          InkWell(
            child: Text(content.last,
                style: TextStyle(
                  color: currTheme.outline,
                  fontWeight: FontWeight.bold,
                  fontSize: Constants.smallFontSize,
                )),
            onTap: () {
              setState(() {
                viewMore = !viewMore;
              });
            },
          )
      ],
    );

    // return RichText(
    //   text: buildComment(),
    // );
  }
}

class _CommentActions extends StatefulWidget {
  const _CommentActions({
    required this.commentId,
    required this.isReply,
    required this.parentNodeId,
    required this.isReplyPage,
  });

  final String commentId;
  final bool isReply;
  final String parentNodeId;

  final bool isReplyPage;

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
                        final nodeCommentProvider =
                            context.read<NodeCommentProvider>();

                        List<UserNodeType> parents = [];
                        if (widget.isReplyPage || widget.isReply) {
                          /// if reply add comment as parent
                          parents.add(UserNodeType(
                            nodeId: nodeCommentProvider.commentTargetId,
                            nodeType: nodeCommentProvider
                                .commentTargetNodeType.nodeType,
                          ));
                        }

                        // add root node
                        parents.add(UserNodeType(
                          nodeId: nodeCommentProvider.rootNodeId,
                          nodeType: nodeCommentProvider.rootNodeType.nodeType,
                        ));

                        // add user
                        parents.add(UserNodeType(
                          nodeId: nodeCommentProvider.rootNodeCreatedBy,
                          nodeType: NodeType.user,
                        ));

                        UserNodeLikeAction payload = UserNodeLikeAction(
                          from: (context.read<UserBloc>().state
                                  as UserCompleteState)
                              .username,
                          to: getUsernameFromUserKey(comment.commentBy),
                          isLike: comment.userLike,
                          likeCount: comment.likesCount,
                          commentCount: comment.commentsCount,
                          nodeId: comment.id,
                          nodeType: NodeType.comment,
                          parents: parents,
                        );

                        context
                            .read<UserActionBloc>()
                            .add(UserActionNodeLikeEvent(
                              nodeId: comment.id,
                              nodeType: DokiNodeType.comment,
                              userLike: !comment.userLike,
                              username: username,
                              client: context
                                  .read<WebsocketClientProvider>()
                                  .client,
                              remotePayload: payload,
                            ));
                      },
                      userLike: comment.userLike,
                      shrinkFactor: 0.875,
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
                    // if (!widget.isReplyPage)
                    TextButton(
                      onPressed: widget.isReplyPage
                          ? null
                          : () {
                              final nodeProvider =
                                  context.read<NodeCommentProvider>();

                              // replies are only shown on comment page
                              if (widget.isReply) {
                                // new node will have commentOn relationship with this node
                                // String targetId =
                                //     widget.isReply ? widget.parentNodeId : commentId;

                                // new node will have replyOn relationship with this node
                                String replyOn = commentId;

                                String targetUsername =
                                    getUsernameFromUserKey(comment.commentBy);

                                nodeProvider
                                  ..updateCommentTarget(
                                    targetUsername,
                                    replyOn,
                                  )
                                  ..focusNode.requestFocus();
                                return;
                              }

                              String currentRoute =
                                  GoRouter.of(context).currentRouteName ?? "";
                              bool isCommentPage =
                                  currentRoute == RouterConstants.comment;

                              if (isCommentPage) {
                                nodeProvider
                                  ..focusNode.requestFocus()
                                  ..resetCommentTarget();
                                return;
                              }

                              final rootNodeId = nodeProvider.rootNodeId;
                              final rootNodeType = nodeProvider.rootNodeType;
                              final rootNodeBy = nodeProvider.rootNodeCreatedBy;

                              context.pushNamed(
                                RouterConstants.comment,
                                pathParameters: {
                                  "rootNodeType": rootNodeType.name,
                                  "rootNodeId": rootNodeId,
                                  "commentId": commentId,
                                  "userId": rootNodeBy,
                                  "parentNodeType": rootNodeType.name,
                                  "parentNodeId": rootNodeId,
                                },
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
                        "Reply",
                      ),
                    ),
                  ],
                ),
                if (!widget.isReply && !widget.isReplyPage)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = MediaQuery.sizeOf(context).width;
                      bool shrink = width < 250;

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
      ],
    );
  }
}
