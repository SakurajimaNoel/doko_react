import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/widgets/like-widget/like_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/media-widget/media_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.postKey,
  });

  final String postKey;

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(postKey)) {
      // send a req to fetch the post
      context.read<UserActionBloc>().add(UserActionGetPostByIdEvent(
            username: username,
            postId: getPostIdFromPostKey(postKey),
          ));
    }

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isPostPage = currentRoute == RouterConstants.userPost;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionPostDataFetchedState &&
            state.postId == getPostIdFromPostKey(postKey);
      },
      builder: (context, state) {
        bool postExists = graph.containsKey(postKey);
        bool isError =
            state is UserActionPostDataFetchedState && !state.success;

        if (!postExists) {
          return LayoutBuilder(
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
                              "Error loading post.",
                              size: Constants.smallFontSize * 1.125,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<UserActionBloc>()
                                    .add(UserActionGetPostByIdEvent(
                                      username: username,
                                      postId: getPostIdFromPostKey(postKey),
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
          );
        }

        final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;
        return InkWell(
          onTap: isPostPage
              ? null
              : () {
                  context.pushNamed(
                    RouterConstants.userPost,
                    pathParameters: {
                      "postId": post.id,
                    },
                  );
                },
          onLongPress: isPostPage
              ? null
              : () {
                  Share.share(
                    context: context,
                    subject: MessageSubject.dokiPost,
                    nodeIdentifier: post.id,
                  );
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Constants.padding * 0.75,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // post meta data
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    bool shrink =
                        constraints.maxWidth < Constants.postMetadataWidth;
                    double shrinkFactor = shrink ? 0.875 : 1;

                    bool superShrink = constraints.maxWidth < 250;
                    double baseFontSize = Constants.smallFontSize * 1.125;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!shrink)
                          UserWidget(
                            userKey: post.createdBy,
                            baseFontSize: baseFontSize,
                            trim: 20,
                          )
                        else
                          UserWidget.small(
                            key: ValueKey("${post.createdBy}-with-small-size"),
                            userKey: post.createdBy,
                            baseFontSize: baseFontSize,
                            trim: 16,
                          ),
                        if (!superShrink)
                          Text(
                            displayDateDifference(
                              post.createdOn,
                              small: shrink,
                            ),
                            style: TextStyle(
                              fontSize: Constants.smallFontSize * shrinkFactor,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
                // post content
                if (post.content.isNotEmpty) ...[
                  const SizedBox(
                    height: Constants.gap * 0.5,
                  ),
                  MediaWidget(
                    mediaItems: post.content,
                    nodeKey: postKey,
                  ),
                  const SizedBox(
                    height: Constants.gap * 0.5,
                  ),
                ],
                const SizedBox(
                  height: Constants.gap * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                    vertical: Constants.padding * 0.5,
                  ),
                  child: _PostCaption(
                    caption: post.caption,
                  ),
                ),
                const SizedBox(
                  height: Constants.gap * 0.5,
                ),
                _PostAction(
                  postId: post.id,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostCaption extends StatefulWidget {
  const _PostCaption({required this.caption});

  final String caption;

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    String displayCaption = viewMore
        ? widget.caption
        : trimText(
            widget.caption,
            len: Constants.postCaptionDisplayLimit,
          );

    bool showButton = widget.caption.length > Constants.postCaptionDisplayLimit;
    String buttonText = viewMore ? "View less" : "View More";

    return RichText(
      text: TextSpan(
        text: displayCaption,
        style: TextStyle(
          color: currTheme.onSurface,
          fontSize: Constants.fontSize,
        ),
        children: showButton
            ? [
                TextSpan(
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
                ),
              ]
            : [],
      ),
    );
  }
}

class _PostAction extends StatefulWidget {
  _PostAction({
    required this.postId,
  }) : graphKey = generatePostNodeKey(postId);

  final String postId;
  final String graphKey;

  @override
  State<_PostAction> createState() => _PostActionState();
}

class _PostActionState extends State<_PostAction> {
  final UserGraph graph = UserGraph();

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final String username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionNodeActionState &&
                state.nodeId == widget.postId) ||
            (state is UserActionPrimaryNodeRefreshState &&
                state.nodeId == widget.postId);
      },
      builder: (context, state) {
        PostEntity post = graph.getValueByKey(widget.graphKey)! as PostEntity;

        return LayoutBuilder(
          builder: (context, constraints) {
            bool shrink = constraints.maxWidth < 285;
            bool superShrink = constraints.maxWidth < 235;

            double shrinkFactor = shrink
                ? 0.75
                : superShrink
                    ? 0.5
                    : 1;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.padding * shrinkFactor,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${displayNumberFormat(post.likesCount)} Like${post.likesCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize:
                              superShrink ? Constants.smallFontSize : null,
                        ),
                      ),
                      Text(
                        "${displayNumberFormat(post.commentsCount)} Comment${post.commentsCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize:
                              superShrink ? Constants.smallFontSize : null,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: Constants.dividerThickness * 0.75,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing:
                        Constants.gap * shrinkFactor - (superShrink ? 0.9 : 0),
                    children: [
                      Row(
                        spacing: Constants.gap * shrinkFactor -
                            (superShrink ? 0.9 : 0),
                        children: [
                          LikeWidget(
                            shrinkFactor: shrinkFactor,
                            onPress: () {
                              UserNodeLikeAction payload = UserNodeLikeAction(
                                from: (context.read<UserBloc>().state
                                        as UserCompleteState)
                                    .username,
                                to: getUsernameFromUserKey(post.createdBy),
                                isLike: post.userLike,
                                likeCount: post.likesCount,
                                commentCount: post.commentsCount,
                                nodeId: post.id,
                                nodeType: NodeType.post,
                                parents: [], // for root node no requirement to get parents
                              );
                              context
                                  .read<UserActionBloc>()
                                  .add(UserActionPostLikeActionEvent(
                                    postId: post.id,
                                    userLike: !post.userLike,
                                    username: username,
                                    client: context
                                        .read<WebsocketClientProvider>()
                                        .client,
                                    remotePayload: payload,
                                  ));
                            },
                            userLike: post.userLike,
                          ),
                          TextButton(
                            onPressed: () {
                              String currentRoute =
                                  GoRouter.of(context).currentRouteName ?? "";
                              bool isPostPage =
                                  currentRoute == RouterConstants.userPost;

                              if (isPostPage) {
                                context.read<NodeCommentProvider>()
                                  ..focusNode.requestFocus()
                                  ..resetCommentTarget();
                                return;
                              }

                              context.pushNamed(
                                RouterConstants.userPost,
                                pathParameters: {
                                  "postId": post.id,
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: currTheme.secondary,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: Constants.padding * shrinkFactor,
                                vertical: Constants.padding * 0.5,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Comment",
                              style: TextStyle(
                                fontSize: superShrink
                                    ? Constants.smallFontSize
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          String currentRoute =
                              GoRouter.of(context).currentRouteName ?? "";
                          bool isPostPage =
                              currentRoute == RouterConstants.userPost;

                          if (isPostPage) {
                            // remove focus
                            FocusManager.instance.primaryFocus?.unfocus();
                          }

                          Share.share(
                            context: context,
                            subject: MessageSubject.dokiPost,
                            nodeIdentifier: post.id,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: currTheme.secondary,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.padding * shrinkFactor,
                            vertical: Constants.padding * 0.5,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Share",
                          style: TextStyle(
                            fontSize:
                                superShrink ? Constants.smallFontSize : null,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
