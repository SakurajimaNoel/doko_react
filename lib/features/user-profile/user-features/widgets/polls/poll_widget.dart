import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-action-widget/content_action_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/content_meta_data_widget.dart';
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Constants.padding * 0.75,
              ),
              child: Column(
                spacing: Constants.gap,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContentMetaDataWidget(
                    nodeKey: pollKey,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                    ),
                    child: Text(
                      poll.question,
                      style: const TextStyle(
                        fontSize: Constants.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _PollOptions(
                    pollKey: pollKey,
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
          ),
        );
      },
    );
  }
}

class _PollOptions extends StatelessWidget {
  const _PollOptions({
    required this.pollKey,
  });

  final String pollKey;

  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();
    final poll = graph.getValueByKey(pollKey)! as PollEntity;

    final currTheme = Theme.of(context).colorScheme;

    return BlocConsumer<UserActionBloc, UserActionState>(
      listenWhen: (prevState, state) {
        return state is UserActionVoteResponse && state.pollId == poll.id;
      },
      listener: (context, state) {
        if (state is UserActionVoteAddFailureState) {
          showError(state.message);
        }
      },
      buildWhen: (prevState, state) {
        return state is UserActionVoteResponse && state.pollId == poll.id;
      },
      builder: (context, state) {
        bool selected = poll.userVote != null;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: Column(
            spacing: Constants.gap * 0.625,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var option in poll.options)
                Builder(
                  builder: (context) {
                    bool displayResult = selected || !poll.isActive;

                    bool myOption = poll.userVote == option.option;
                    final color = !displayResult
                        ? Colors.transparent
                        : myOption
                            ? currTheme.primaryContainer
                            : currTheme.secondaryContainer;

                    double percentage =
                        getPercentageDouble(option.voteCount, poll.totalVotes);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Constants.radius * 0.625),
                        border: Border.all(
                          width: 1.5,
                          color: displayResult ? color : currTheme.outline,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      width: double.infinity,
                      child: InkWell(
                          onTap: !poll.isActive || myOption
                              ? null
                              : () {
                                  context
                                      .read<UserActionBloc>()
                                      .add(UserActionAddVoteToPollEvent(
                                        pollId: poll.id,
                                        username: (context
                                                .read<UserBloc>()
                                                .state as UserCompleteState)
                                            .username,
                                        option: option.option,
                                      ));
                                },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                stops: [
                                  percentage,
                                  1.0,
                                ],
                                colors: [
                                  color,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Constants.padding * 0.625),
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                child: displayResult
                                    ? Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        runSpacing: Constants.gap * 0.5,
                                        children: [
                                          myOption
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  spacing: Constants.gap * 0.5,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      size: Constants
                                                              .iconButtonSize *
                                                          0.5,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                          option.optionValue),
                                                    ),
                                                  ],
                                                )
                                              : Text(option.optionValue),
                                          Text(getPercentage(option.voteCount,
                                              poll.totalVotes)),
                                        ],
                                      )
                                    : Text(
                                        option.optionValue,
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ),
                          )),
                    );
                  },
                ),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: Constants.smallFontSize,
                  fontWeight: FontWeight.w500,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: Constants.gap * 0.25,
                  children: [
                    const SizedBox(
                      width: double.infinity,
                    ),
                    Text(getPollStatusText(poll.activeTill)),
                    Text(
                      "${displayNumberFormat(poll.totalVotes)} Votes",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
