import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/provider/post_carousel_indicator_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PostPreviewWidget extends StatelessWidget {
  const PostPreviewWidget({
    super.key,
    required this.postKey,
  });

  final String postKey;

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    if (!graph.containsKey(postKey)) {
      // send a req to fetch the post
      context.read<UserActionBloc>().add(UserActionGetPostByIdEvent(
            username: username,
            postId: getPostIdFromPostKey(postKey),
          ));
    }

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            bool shrink = width < 220;
            bool superShrink = width < 175;
            double shrinkFactor = shrink ? 0.75 : 1;

            return Column(
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: Constants.gap * 0.75 * shrinkFactor,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserWidget.avtarSmall(
                      userKey: post.createdBy,
                    ),
                    SizedBox(
                      child: UserWidget.infoSmall(
                        userKey: post.createdBy,
                        trim: superShrink ? 12 : 16,
                        baseFontSize: Constants.smallFontSize,
                      ),
                    ),
                    if (!shrink) ...[
                      const Spacer(),
                      BlocBuilder<UserActionBloc, UserActionState>(
                        buildWhen: (previousState, state) {
                          return (state is UserActionNodeActionState &&
                                  state.nodeId == post.id) ||
                              (state is UserActionPostRefreshState &&
                                  state.nodeId == post.id);
                        },
                        builder: (context, state) {
                          if (shrink) return const SizedBox.shrink();

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: Constants.gap * 0.125,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                spacing: Constants.gap * 0.25,
                                children: [
                                  Text(
                                    displayNumberFormat(post.likesCount),
                                    style: const TextStyle(
                                      fontSize: Constants.smallFontSize * 0.875,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.thumb_up,
                                    size: Constants.iconButtonSize * 0.25,
                                  )
                                ],
                              ),
                              Row(
                                spacing: Constants.gap * 0.25,
                                children: [
                                  Text(
                                    displayNumberFormat(post.commentsCount),
                                    style: const TextStyle(
                                      fontSize: Constants.smallFontSize * 0.875,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.comment_rounded,
                                    size: Constants.iconButtonSize * 0.25,
                                  )
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
                if (post.content.isNotEmpty)
                  ChangeNotifierProvider(
                    create: (_) => PostCarouselIndicatorProvider(
                      currentItem: post.currDisplay,
                      width: width,
                    ),
                    child: PostContent.preview(
                      content: post.content,
                      postId: post.id,
                    ),
                  ),
                Text(trimText(post.caption)),
              ],
            );
          },
        );
      },
    );
  }
}
