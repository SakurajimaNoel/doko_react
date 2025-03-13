import 'dart:math';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'types.dart';

class UserQuickActionWidget extends StatelessWidget {
  const UserQuickActionWidget({
    super.key,
  });

  static void showUserModal({
    required BuildContext context,
    required QuickActionComplete onDone,
    List<String>? selected,
    bool onlyFriends = true,
    required int limit,
    required String limitReachedLabel,
    String actionLabel = "Done",
    Widget? whenEmptySelection,
  }) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          builder: (BuildContext context, ScrollController controller) {
            final username =
                (context.read<UserBloc>().state as UserCompleteState).username;
            final UserProfileNodesInput details = UserProfileNodesInput(
              username: username,
              currentUsername: username,
            );

            return BlocProvider(
              create: (context) => serviceLocator<ProfileBloc>()
                ..add(GetUserFriendsEvent(
                  userDetails: details,
                )),
              child: _GetUserDetails(
                controller: controller,
                onlyFriends: onlyFriends,
                onDone: onDone,
                selected: selected ?? [],
                limit: limit,
                limitReachedLabel: limitReachedLabel,
                actionLabel: actionLabel,
                whenEmptySelection: whenEmptySelection,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Text(
        "Use static method \"getUserModal\" to allow selection of users.");
  }
}

class _GetUserDetails extends StatefulWidget {
  const _GetUserDetails({
    required this.controller,
    required this.onlyFriends,
    required this.onDone,
    required this.selected,
    required this.limit,
    required this.limitReachedLabel,
    required this.actionLabel,
    this.whenEmptySelection,
  });

  final ScrollController controller;
  final bool onlyFriends;

  final QuickActionComplete onDone;
  final List<String> selected;

  final int limit;
  final String limitReachedLabel;

  final String actionLabel;
  final Widget? whenEmptySelection;

  @override
  State<_GetUserDetails> createState() => _GetUserDetailsState();
}

class _GetUserDetailsState extends State<_GetUserDetails> {
  late final List<String> selectedUsers = widget.selected;
  bool loading = false;
  final UserGraph graph = UserGraph();
  late final String username;
  late final String graphKey;
  final TextEditingController queryController = TextEditingController();

  late final bool onlyFriends = widget.onlyFriends;

  List<String> tempSearchResults = [];
  bool handlingDone = false;

  @override
  void initState() {
    super.initState();

    username = (context.read<UserBloc>().state as UserCompleteState).username;

    graphKey = generateUserNodeKey(username);
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void onUserSelect(String username) {
    int selectedLength = selectedUsers.length;
    bool selected = selectedUsers.contains(username);
    if (selected) {
      selectedUsers.remove(username);
    } else {
      if (selectedLength < widget.limit) {
        selectedUsers.add(username);
      } else {
        showInfo(widget.limitReachedLabel);
        return;
      }
    }

    setState(() {});
  }

  Widget buildFriendItems(
      BuildContext context, int index, List<String> displayFriends) {
    final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
    final Nodes userFriends = user.friends;

    if (index >= displayFriends.length) {
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
                currentUsername: username,
              ),
            ));
      }

      return const Center(
        child: LoadingWidget.small(),
      );
    }

    final userKey = displayFriends[index];
    bool isSelected = selectedUsers.contains(
      getUsernameFromUserKey(userKey),
    );

    return _GetUserWidget(
      key: ValueKey("friends-$userKey"),
      userKey: userKey,
      onUserSelect: onUserSelect,
      isSelected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = min(MediaQuery.sizeOf(context).width, Constants.compact);

    final itemSize = 130;

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: (width ~/ itemSize),
      mainAxisSpacing: Constants.gap * 0.5,
      crossAxisSpacing: Constants.gap * 0.5,
    );

    final currTheme = Theme.of(context).colorScheme;

    final UserProfileNodesInput details = UserProfileNodesInput(
      username: username,
      currentUsername: username,
    );

    bool showEmptySelection =
        widget.whenEmptySelection != null && selectedUsers.isEmpty;

    return SizedBox(
      width: width,
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
          List<String> searchDisplay = tempSearchResults.toList();
          searchDisplay.removeWhere((String userKey) => selectedUsers.contains(
                getUsernameFromUserKey(userKey),
              ));

          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: LoadingWidget.small(),
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

          final user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
          final Nodes userFriends = user.friends;

          List<String> displayFriends = userFriends.items.toList();
          displayFriends.removeWhere(
            (String userKey) => selectedUsers.contains(
              getUsernameFromUserKey(userKey),
            ),
          );

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: CustomScrollView(
                    cacheExtent: height,
                    controller: widget.controller,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: Constants.padding * 0.125,
                                ),
                                child: TextField(
                                  controller: queryController,
                                  minLines: 1,
                                  maxLines: 2,
                                  onChanged: (String value) {
                                    if (onlyFriends) {
                                      UserFriendsSearchInput searchDetails =
                                          UserFriendsSearchInput(
                                        username: username,
                                        query: value,
                                        currentUsername: username,
                                      );

                                      context
                                          .read<ProfileBloc>()
                                          .add(UserFriendsSearchEvent(
                                            searchDetails: searchDetails,
                                          ));

                                      return;
                                    }

                                    if (value.isEmpty) {
                                      setState(() {});
                                      return;
                                    }

                                    UserSearchInput searchDetails =
                                        UserSearchInput(
                                      username: username,
                                      query: value,
                                    );

                                    context
                                        .read<ProfileBloc>()
                                        .add(UserSearchEvent(
                                          searchDetails: searchDetails,
                                        ));
                                  },
                                  decoration: const InputDecoration(
                                    hintText:
                                        "Search users by name or username",
                                  ),
                                ),
                              ),
                              if (searching)
                                const Padding(
                                  padding: EdgeInsets.only(
                                    right: Constants.padding * 0.125,
                                  ),
                                  child: LoadingWidget.small(),
                                ),
                              if (!searching && state is! ProfileInitial)
                                Icon(
                                  Icons.check,
                                  color: currTheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap,
                        ),
                      ),
                      if (selectedUsers.isNotEmpty)
                        SliverGrid.builder(
                          gridDelegate: gridDelegate,
                          itemCount: selectedUsers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final username = selectedUsers[index];

                            return _GetUserWidget(
                              key: ValueKey("selected-$username"),
                              userKey: generateUserNodeKey(username),
                              onUserSelect: onUserSelect,
                              isSelected: selectedUsers.contains(username),
                            );
                          },
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap * 0.5,
                        ),
                      ),
                      searchResult
                          ? tempSearchResults.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Center(
                                    child: Text(
                                        "No user found with \"${queryController.text.trim()}\""),
                                  ),
                                )
                              : SliverGrid.builder(
                                  gridDelegate: gridDelegate,
                                  itemCount: searchDisplay.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final userKey = searchDisplay[index];
                                    bool isSelected = selectedUsers.contains(
                                      getUsernameFromUserKey(userKey),
                                    );

                                    return _GetUserWidget(
                                      key: ValueKey("search-$userKey"),
                                      userKey: userKey,
                                      onUserSelect: onUserSelect,
                                      isSelected: isSelected,
                                    );
                                  },
                                )
                          : userFriends.items.isEmpty
                              ? const SliverToBoxAdapter(
                                  child: Center(
                                    child: Text(
                                      "You don't have friends right now.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : SliverGrid.builder(
                                  gridDelegate: gridDelegate,
                                  itemCount: displayFriends.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return buildFriendItems(
                                        context, index, displayFriends);
                                  },
                                ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Constants.padding),
                child: showEmptySelection
                    ? widget.whenEmptySelection
                    : FilledButton(
                        onPressed: () async {
                          if (handlingDone) return;
                          handlingDone = true;
                          // call value setter from parents
                          if (await widget.onDone(selectedUsers)) {
                            contextPop();
                          } else {
                            handlingDone = false;
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            Constants.buttonWidth,
                            Constants.buttonHeight,
                          ),
                        ),
                        child: Text(widget.actionLabel),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void contextPop() {
    context.pop();
  }
}

class _GetUserWidget extends StatelessWidget {
  const _GetUserWidget({
    required super.key,
    required this.userKey,
    required this.onUserSelect,
    required this.isSelected,
  });

  final String userKey;
  final bool isSelected;
  final ValueSetter<String> onUserSelect;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final friendUsername = getUsernameFromUserKey(userKey);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius),
        color: isSelected
            ? currTheme.primaryContainer.withValues(
                alpha: 0.75,
              )
            : Colors.transparent,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onUserSelect(friendUsername);
          },
          child: Padding(
            padding: const EdgeInsets.all(Constants.padding * 0.25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserWidget.avtarLarge(
                  userKey: userKey,
                ),
                Expanded(
                  child: Column(
                    spacing: Constants.gap * 0.125,
                    children: [
                      Flexible(
                        child: UserWidget.name(
                          userKey: userKey,
                        ),
                      ),
                      Flexible(
                        child: UserWidget.username(
                          userKey: userKey,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _widget;

  _SliverAppBarDelegate(this._widget);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final currTheme = Theme.of(context).colorScheme;
    return Container(
      color: currTheme.surfaceContainerLow,
      child: _widget,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
