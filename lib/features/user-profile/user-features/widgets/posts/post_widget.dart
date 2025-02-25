import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-action-widget/content_action_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/content_meta_data_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/media_widget.dart';
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
        return state is UserActionNodeDataFetchedState &&
            state.nodeId == getPostIdFromPostKey(postKey);
      },
      builder: (context, state) {
        bool postExists = graph.containsKey(postKey);
        bool isError =
            state is UserActionNodeDataFetchedState && !state.success;

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
              spacing: Constants.gap * 0.5,
              mainAxisSize: MainAxisSize.min,
              children: [
                // post meta data
                ContentMetaDataWidget(
                  nodeKey: postKey,
                ),
                // post content
                if (post.content.isNotEmpty)
                  MediaWidget(
                    mediaItems: post.content,
                    nodeKey: postKey,
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
                ContentActionWidget(
                  nodeId: post.id,
                  nodeType: DokiNodeType.post,
                  isNodePage: isPostPage,
                  redirectToNodePage: () {
                    context.pushNamed(
                      RouterConstants.userPost,
                      pathParameters: {
                        "postId": post.id,
                      },
                    );
                  },
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
