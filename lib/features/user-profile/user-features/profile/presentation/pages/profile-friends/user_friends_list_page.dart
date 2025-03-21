import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/expanded_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
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

  final TextEditingController queryController = TextEditingController();
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
  }

  Widget buildFriendItems(BuildContext context, int index) {
    final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
    final Nodes userFriends = user.friends;

    if (index >= userFriends.items.length) {
      /// fetch more friends if exits
      if (!userFriends.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      // fetch more friends
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(GetUserFriendsEvent(
              userDetails: UserProfileNodesInput(
                username: username,
                cursor: userFriends.pageInfo.endCursor!,
                currentUsername: currentUsername,
              ),
            ));
      }

      return const Center(
        child: LoadingWidget.small(),
      );
    }

    // show user friend widget
    return ExpandedBox(
      child: FriendWidget(
        userKey: userFriends.items[index],
        key: ValueKey(userFriends.items[index]),
      ),
    );
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProfileNodesInput details = UserProfileNodesInput(
      username: username,
      currentUsername: currentUsername,
    );

    final currTheme = Theme.of(context).colorScheme;

    List<String> tempSearchResults = [];

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
          padding: const EdgeInsets.only(
            bottom: Constants.padding,
          ),
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listenWhen: (previousState, state) {
              return state is ProfileNodeLoadResponse;
            },
            listener: (context, state) {
              loading = false;
              String errorMessage = "";

              if (state is ProfileNodeLoadError) {
                errorMessage = state.message;
              }
              if (state is ProfileUserSearchErrorState) {
                errorMessage = state.message;
              }

              if (errorMessage.isNotEmpty) {
                showError(errorMessage);
                return;
              }

              // handle friends load success
              final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
              final Nodes userFriends = user.friends;

              context
                  .read<UserToUserActionBloc>()
                  .add(UserToUserActionNodesLoadEvent(
                    itemCount: userFriends.items.length,
                    username: username,
                    nodeType: DokiNodeType.user,
                  ));
            },
            buildWhen: (previousState, state) {
              return state is! ProfileNodeLoadResponse;
            },
            builder: (context, state) {
              bool searching = state is ProfileUserSearchLoadingState;
              bool searchResult = state is ProfileUserSearchSuccessState &&
                  queryController.text.trim().isNotEmpty;
              if (searchResult) {
                tempSearchResults = state.searchResults;
              }

              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: LoadingWidget(),
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
                          context.read<ProfileBloc>().add(GetUserFriendsEvent(
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
              return PullToRefresh(
                onRefresh: () async {
                  Future profileBloc = context.read<ProfileBloc>().stream.first;

                  context.read<ProfileBloc>().add(GetUserFriendsRefreshEvent(
                        userDetails: details,
                      ));
                  queryController.clear();
                  FocusScope.of(context).unfocus();

                  final ProfileState state = await profileBloc;
                  if (state is ProfileRefreshError) {
                    showError(state.message);
                  }
                },
                child: BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
                  buildWhen: (previousState, state) {
                    return (state is UserToUserActionLoadNodesState &&
                            state.username == username &&
                            state.nodeType == DokiNodeType.user) ||
                        (state is UserToUserActionUpdateUserAcceptedFriendsListState &&
                            (self || state.username == username));
                  },
                  builder: (context, state) {
                    final user =
                        graph.getValueByKey(graphKey)! as CompleteUserEntity;
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

                    return Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExpandedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Constants.padding,
                            ),
                            child: Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                TextField(
                                  controller: queryController,
                                  onChanged: (String value) {
                                    UserFriendsSearchInput searchDetails =
                                        UserFriendsSearchInput(
                                      username: username,
                                      query: value,
                                      currentUsername: currentUsername,
                                    );

                                    context
                                        .read<ProfileBloc>()
                                        .add(UserFriendsSearchEvent(
                                          searchDetails: searchDetails,
                                        ));
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Search",
                                    hintText:
                                        "Search user by username or name.",
                                  ),
                                ),
                                if (searching) const LoadingWidget.small(),
                                if (!searching && state is! ProfileInitial)
                                  Icon(
                                    Icons.check,
                                    color: currTheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: Constants.gap * 2,
                        ),
                        Flexible(
                          child: searchResult
                              ? tempSearchResults.isEmpty
                                  ? Center(
                                      child: Text(
                                          "No user found with \"${queryController.text.trim()}\""),
                                    )
                                  : ListView.separated(
                                      itemCount: tempSearchResults.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ExpandedBox(
                                          child: FriendWidget(
                                            userKey: tempSearchResults[index],
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const SizedBox(
                                          height: Constants.gap * 0.5,
                                        );
                                      },
                                    )
                              : ListView.separated(
                                  itemCount: userFriends.items.length + 1,
                                  itemBuilder: buildFriendItems,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const SizedBox(
                                      height: Constants.gap * 0.5,
                                    );
                                  },
                                ),
                        ),
                      ],
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
