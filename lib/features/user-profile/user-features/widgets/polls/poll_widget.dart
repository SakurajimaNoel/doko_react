import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-action-widget/content_action_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PollWidget extends StatelessWidget {
  const PollWidget({
    super.key,
    required this.pollKey,
  });

  final String pollKey;

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    if (!graph.containsKey(pollKey)) {
      // send a req to fetch the discussion
      context.read<UserActionBloc>().add(UserActionGetPollByIdEvent(
            username: username,
            pollId: getPollIdFromPollKey(pollKey),
          ));
    }

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isPollPage = currentRoute == RouterConstants.userPoll;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNodeDataFetchedState &&
            state.nodeId == getPollIdFromPollKey(pollKey);
      },
      builder: (context, state) {
        bool pollExists = graph.containsKey(pollKey);
        bool isError =
            state is UserActionNodeDataFetchedState && !state.success;

        if (!pollExists) {
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
                              "Error loading poll.",
                              size: Constants.smallFontSize * 1.125,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<UserActionBloc>()
                                    .add(UserActionGetPollByIdEvent(
                                      username: username,
                                      pollId: getPollIdFromPollKey(pollKey),
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
        final PollEntity poll = graph.getValueByKey(pollKey)! as PollEntity;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isPollPage
                ? null
                : () {
                    context.pushNamed(
                      RouterConstants.userPoll,
                      pathParameters: {
                        "pollId": poll.id,
                      },
                    );
                  },
            onLongPress: isPollPage
                ? null
                : () {
                    Share.share(
                      context: context,
                      subject: MessageSubject.dokiPolls,
                      nodeIdentifier: poll.id,
                    );
                  },
            child: Column(
              spacing: Constants.gap,
              children: [
                Container(
                  color: Colors.green,
                  height: Constants.height * 15,
                  child: Center(
                    child: Text(poll.question),
                  ),
                ),
                ContentActionWidget(
                  nodeId: poll.id,
                  nodeType: DokiNodeType.poll,
                  isNodePage: isPollPage,
                  redirectToNodePage: () {
                    context.pushNamed(
                      RouterConstants.userPoll,
                      pathParameters: {
                        "pollId": poll.id,
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
