import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/friend_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserFriendsListPage extends StatefulWidget {
  const UserFriendsListPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<UserFriendsListPage> createState() => _UserFriendsListPageState();
}

class _UserFriendsListPageState extends State<UserFriendsListPage> {
  late final String username;
  late final String currentUsername;
  late final bool self;

  late final CompleteUserEntity user;
  late final String graphKey;
  final graph = UserGraph();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    self = username == currentUsername;
    graphKey = generateUserNodeKey(username);

    /// map makes data by reference so no need to refetch the data
    /// just need to trigger rebuild when data is updated
    /// and latest data will be shown in the feed
    user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  Widget buildFriendItems(BuildContext context, int index) {
    final Nodes userFriends = user.friends;

    if (index >= userFriends.items.length) {
      /// fetch more friends if exits
      if (!userFriends.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      // fetch more friends
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(LoadMoreProfileFriendsEvent(
              friendDetails: UserProfileNodesInput(
                username: username,
                cursor: userFriends.pageInfo.endCursor!,
                currentUsername: currentUsername,
              ),
            ));
      }

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    // show user friend widget
    return FriendWidget(
      userKey: userFriends.items[index],
      key: ValueKey(userFriends.items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GetProfileInput details = GetProfileInput(
      username: username,
      currentUsername: currentUsername,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("$username friends"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<ProfileBloc>()
          ..add(GetUserFriendsEvent(
            userDetails: details,
          )),
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (previousState, state) {
              return state is ProfileFriendLoadResponse;
            },
            listener: (context, state) {
              loading = false;

              if (state is ProfileFriendLoadError) {
                showMessage(state.message);
                return;
              }

              // handle friends load success
              final Nodes userFriends = user.friends;

              context.read<UserActionBloc>().add(UserActionFriendLoadEvent(
                    friendsCount: userFriends.items.length,
                    username: username,
                  ));
            },
            buildWhen: (previousState, state) {
              return state is! ProfileFriendLoadResponse;
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
                          context.read<ProfileBloc>().add(GetUserProfileEvent(
                                userDetails: details,
                              ));
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              // render profile friends
              return RefreshIndicator(
                onRefresh: () async {
                  Future profileBloc = context.read<ProfileBloc>().stream.first;

                  context.read<ProfileBloc>().add(GetUserFriendsRefreshEvent(
                        userDetails: details,
                      ));

                  final ProfileState state = await profileBloc;
                  if (state is ProfileRefreshError) {
                    showMessage(state.message);
                  }
                },
                child: BlocBuilder<UserActionBloc, UserActionState>(
                  buildWhen: (previousState, state) {
                    return (state is UserActionLoadFriends &&
                            state.username == username) ||
                        (state is UserActionUpdateUserAcceptedFriendsListState &&
                            (self || state.username == username));
                  },
                  builder: (context, state) {
                    final Nodes userFriends = user.friends;

                    if (userFriends.items.isEmpty) {
                      return CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "${user.name} has no friends right now.",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }

                    return ListView.separated(
                      itemCount: userFriends.items.length + 1,
                      itemBuilder: buildFriendItems,
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: Constants.gap * 1.5,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
