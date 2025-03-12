import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/content_meta_data_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscussionPreviewWidget extends StatelessWidget {
  const DiscussionPreviewWidget({
    super.key,
    required this.discussionKey,
  });

  final String discussionKey;

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    if (!graph.containsKey(discussionKey)) {
      // send a req to fetch the discussion
      context.read<UserActionBloc>().add(UserActionGetDiscussionByIdEvent(
            username: username,
            discussionId: getDiscussionIdFromDiscussionKey(discussionKey),
          ));
    }

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNodeDataFetchedState &&
            state.nodeId == getDiscussionIdFromDiscussionKey(discussionKey);
      },
      builder: (context, state) {
        bool discussionExists = graph.containsKey(discussionKey);
        bool isError =
            state is UserActionNodeDataFetchedState && !state.success;

        if (!discussionExists) {
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
                              "Error loading discussion.",
                              size: Constants.smallFontSize * 1.125,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<UserActionBloc>()
                                    .add(UserActionGetDiscussionByIdEvent(
                                      username: username,
                                      discussionId:
                                          getDiscussionIdFromDiscussionKey(
                                              discussionKey),
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
        final DiscussionEntity discussion =
            graph.getValueByKey(discussionKey)! as DiscussionEntity;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Column(
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ContentMetaDataPreviewWidget(
                  nodeType: DokiNodeType.discussion,
                  nodeId: discussion.id,
                ),
                Heading.left(
                  discussion.title,
                  size: Constants.fontSize * 1.25,
                ),
                if (discussion.media.isNotEmpty)
                  MediaWidget.preview(
                    mediaItems: discussion.media,
                    nodeKey: discussionKey,
                    width: width,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
