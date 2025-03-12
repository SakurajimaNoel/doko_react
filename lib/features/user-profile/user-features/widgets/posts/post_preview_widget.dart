import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/content_meta_data_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Column(
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ContentMetaDataPreviewWidget(
                  nodeType: DokiNodeType.post,
                  nodeId: post.id,
                ),
                if (post.content.isNotEmpty)
                  MediaWidget.preview(
                    mediaItems: post.content,
                    nodeKey: postKey,
                    width: width,
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
