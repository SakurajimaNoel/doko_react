import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/friend_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingOutgoingRequest extends StatefulWidget {
  const PendingOutgoingRequest({super.key});

  @override
  State<PendingOutgoingRequest> createState() => _PendingOutgoingRequestState();
}

class _PendingOutgoingRequestState extends State<PendingOutgoingRequest>
    with AutomaticKeepAliveClientMixin {
  late final String username;

  bool loading = false;
  final UserGraph graph = UserGraph();
  final String graphKey = generatePendingOutgoingReqKey();

  @override
  void initState() {
    super.initState();

    username = (context.read<UserBloc>().state as UserCompleteState).username;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
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
        context.read<ProfileBloc>().add(PendingOutgoingRequestMore(
              username: username,
              cursor: pendingRequest.pageInfo.endCursor!,
            ));
      }

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    // show user friend widget
    return FriendWidget(
      userKey: pendingRequest.items[index],
      key: ValueKey(pendingRequest.items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => serviceLocator<ProfileBloc>()
        ..add(PendingOutgoingRequestInitial(
          username: username,
        )),
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previousState, state) {
            return state is PendingRequestLoadResponse;
          },
          listener: (context, state) {
            loading = false;

            if (state is PendingRequestLoadError) {
              showMessage(state.message);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StyledText.error(state.message),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(PendingOutgoingRequestInitial(
                              username: username,
                              refresh: true,
                            ));
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(PendingOutgoingRequestInitial(
                      username: username,
                      refresh: true,
                    ));
              },
              child: BlocBuilder<UserActionBloc, UserActionState>(
                buildWhen: (previousState, state) {
                  return state is UserActionUpdateUserPendingFriendsListState;
                },
                builder: (context, state) {
                  final Nodes pendingRequest =
                      graph.getValueByKey(graphKey)! as Nodes;

                  if (pendingRequest.items.isEmpty) {
                    return const CustomScrollView(
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
                    );
                  }

                  return ListView.separated(
                    itemCount: pendingRequest.items.length + 1,
                    itemBuilder: buildRequestItems,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: Constants.gap,
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
