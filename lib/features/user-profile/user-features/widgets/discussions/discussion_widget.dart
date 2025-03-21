import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/markdown-display-widget/markdown_display_widget.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-action-widget/content_action_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/content_meta_data_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DiscussionWidget extends StatelessWidget {
  const DiscussionWidget({
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

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isDiscussionPage = currentRoute == RouterConstants.userDiscussion;

    double scaleFactor = isDiscussionPage ? 1.125 : 1;

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
                      : const LoadingWidget.small(),
                ),
              );
            },
          );
        }
        final DiscussionEntity discussion =
            graph.getValueByKey(discussionKey)! as DiscussionEntity;

        return InkWell(
          onTap: isDiscussionPage
              ? null
              : () {
                  context.pushNamed(
                    RouterConstants.userDiscussion,
                    pathParameters: {
                      "discussionId": discussion.id,
                    },
                  );
                },
          onLongPress: isDiscussionPage
              ? null
              : () {
                  Share.share(
                    context: context,
                    subject: MessageSubject.dokiDiscussion,
                    nodeIdentifier: discussion.id,
                  );
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Constants.padding * 0.75,
            ),
            child: Column(
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ContentMetaDataWidget(
                  nodeKey: discussionKey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                    vertical: Constants.padding * 0.5,
                  ),
                  child: Heading.left(
                    discussion.title,
                    size: Constants.heading4 * scaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (discussion.media.isNotEmpty) ...[
                  MediaWidget(
                    nodeKey: discussionKey,
                  ),
                  if (!isDiscussionPage)
                    const SizedBox(
                      height: Constants.gap * 0.5,
                    ),
                ],
                if (isDiscussionPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                      vertical: Constants.padding * 0.5,
                    ),
                    child: MarkdownDisplayWidget(
                      data: discussion.text,
                    ),
                  ),
                ContentActionWidget(
                  nodeId: discussion.id,
                  nodeType: DokiNodeType.discussion,
                  isNodePage: isDiscussionPage,
                  redirectToNodePage: () {
                    context.pushNamed(
                      RouterConstants.userDiscussion,
                      pathParameters: {
                        "discussionId": discussion.id,
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
