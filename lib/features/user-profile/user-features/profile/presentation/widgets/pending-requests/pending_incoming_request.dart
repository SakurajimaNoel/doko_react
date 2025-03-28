import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/expanded_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/friend_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingIncomingRequest extends StatefulWidget {
  const PendingIncomingRequest({super.key});

  @override
  State<PendingIncomingRequest> createState() => _PendingIncomingRequestState();
}

class _PendingIncomingRequestState extends State<PendingIncomingRequest>
    with AutomaticKeepAliveClientMixin {
  late final String username;

  bool loading = false;
  final UserGraph graph = UserGraph();
  final String graphKey = generatePendingIncomingReqKey();

  @override
  void initState() {
    super.initState();

    username = (context.read<UserBloc>().state as UserCompleteState).username;
  }

  Widget buildRequestItems(BuildContext context, int index) {
    final Nodes pendingRequest = graph.getValueByKey(graphKey)! as Nodes;

    if (index >= pendingRequest.items.length) {
      /// fetch more friends if exits
      if (!pendingRequest.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      // fetch more friends
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(GetUserPendingIncomingRequest(
              username: username,
              cursor: pendingRequest.pageInfo.endCursor!,
            ));
      }

      return const Center(
        child: LoadingWidget.small(),
      );
    }

    // show user friend widget
    return ExpandedBox(
      key: ValueKey(pendingRequest.items[index]),
      child: FriendWidget(
        userKey: pendingRequest.items[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => serviceLocator<ProfileBloc>()
        ..add(GetUserPendingIncomingRequest(
          username: username,
        )),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Constants.padding,
        ),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previousState, state) {
            return state is PendingRequestLoadResponse;
          },
          listener: (context, state) {
            loading = false;

            if (state is PendingRequestLoadError) {
              showError(state.message);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            return PullToRefresh(
              onRefresh: () async {
                context.read<ProfileBloc>().add(GetUserPendingIncomingRequest(
                      username: username,
                      refresh: true,
                    ));
              },
              child: BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
                buildWhen: (previousState, state) {
                  return state
                      is UserToUserActionUpdateUserPendingFriendsListState;
                },
                builder: (context, state) {
                  final pendingRequest = graph.getValueByKey(graphKey);

                  if (pendingRequest is! Nodes ||
                      pendingRequest.items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.padding,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "You have no pending incoming requests",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: pendingRequest.items.length + 1,
                    itemBuilder: buildRequestItems,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: Constants.gap * 0.5,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
