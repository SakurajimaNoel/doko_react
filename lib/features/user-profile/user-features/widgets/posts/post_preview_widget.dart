import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
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

        if (!postExists) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxWidth,
                child: const Center(
                  child: SmallLoadingIndicator.small(),
                ),
              );
            },
          );
        }

        final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            bool shrink = width < 235;
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
                      width: shrink ? width / 1.5 : null,
                      child: UserWidget.infoSmall(
                        userKey: post.createdBy,
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
                            spacing: Constants.gap * 0.25,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${displayNumberFormat(post.likesCount)} Like${post.likesCount > 1 ? "s" : ""}",
                                style: const TextStyle(
                                  fontSize: Constants.smallFontSize,
                                ),
                              ),
                              Text(
                                "${displayNumberFormat(post.commentsCount)} Comment${post.commentsCount > 1 ? "s" : ""}",
                                style: const TextStyle(
                                  fontSize: Constants.smallFontSize,
                                ),
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
