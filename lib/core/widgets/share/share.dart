import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
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
import 'package:share_plus/share_plus.dart' as share_external;

class Share extends StatelessWidget {
  const Share({
    super.key,
  });

  static void share({
    required BuildContext context,
    required MessageSubject subject,
    required String nodeIdentifier,
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
              child: _ShareDetails(
                controller: controller,
                subject: subject,
                nodeIdentifier: nodeIdentifier,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Text("Use static method \"share\" to allow sharing.");
  }
}

class _ShareDetails extends StatefulWidget {
  const _ShareDetails({
    required this.controller,
    required this.subject,
    required this.nodeIdentifier,
  });

  final ScrollController controller;
  final MessageSubject subject;
  final String nodeIdentifier;

  @override
  State<_ShareDetails> createState() => _ShareDetailsState();
}

class _ShareDetailsState extends State<_ShareDetails> {
  List<String> selectedUsers = [];
  bool loading = false;
  final UserGraph graph = UserGraph();
  late final String username;
  late final String graphKey;
  final TextEditingController queryController = TextEditingController();

  List<String> tempSearchResults = [];

  /// used to prevent duplicate sending of same payload when attempting to reconnect
  bool sending = false;

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
      if (selectedLength < Constants.shareLimit) {
        selectedUsers.add(username);
      } else {
        showInfo("You can send up to ${Constants.shareLimit} users at a time.");
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
        child: SmallLoadingIndicator(),
      );
    }

    final userKey = displayFriends[index];
    bool isSelected = selectedUsers.contains(
      getUsernameFromUserKey(userKey),
    );

    return _ShareUserWidget(
      key: ValueKey("friends-$userKey"),
      userKey: userKey,
      onUserSelect: onUserSelect,
      isSelected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

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

    int selectedLength = selectedUsers.length;
    String sendText = selectedUsers.isEmpty
        ? "Send"
        : "Send to $selectedLength user${selectedLength > 1 ? "s" : ""}";

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
          searchDisplay.removeWhere(
            (String userKey) =>
                selectedUsers.contains(
                  getUsernameFromUserKey(userKey),
                ) ||
                username == getUsernameFromUserKey(userKey),
          );

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
                                  child: SmallLoadingIndicator(),
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

                            return _ShareUserWidget(
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

                                    return _ShareUserWidget(
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
                child: selectedUsers.isEmpty
                    ? FilledButton.tonal(
                        onPressed: () {
                          final String baseUrl = "https://doki.co.in";
                          String url;
                          String supportingText;

                          switch (widget.subject) {
                            case MessageSubject.dokiUser:
                              url = "$baseUrl/user/${widget.nodeIdentifier}";
                              supportingText =
                                  "Check @${widget.nodeIdentifier} profile on doki.";
                            case MessageSubject.dokiPost:
                              url = "$baseUrl/post/${widget.nodeIdentifier}";
                              supportingText = "Check this Post on doki.";
                            case MessageSubject.dokiPage:
                              url = "$baseUrl/page/${widget.nodeIdentifier}";
                              supportingText = "Check this Page on doki.";
                            case MessageSubject.dokiDiscussion:
                              url =
                                  "$baseUrl/discussion/${widget.nodeIdentifier}";
                              supportingText = "Check this Discussion on doki.";
                            case MessageSubject.dokiPolls:
                              url = "$baseUrl/poll/${widget.nodeIdentifier}";
                              supportingText = "Check this Poll on doki.";
                            default:
                              url = "";
                              supportingText = "";
                          }

                          if (url.isEmpty || supportingText.isEmpty) return;

                          share_external.Share.share(
                            url,
                            subject: supportingText,
                          );
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            Constants.buttonWidth,
                            Constants.buttonHeight,
                          ),
                        ),
                        child: const Text("More share options."),
                      )
                    : FilledButton(
                        onPressed: selectedUsers.isEmpty
                            ? null
                            : () async {
                                if (sending) return;
                                sending = true;

                                final client = context
                                    .read<WebsocketClientProvider>()
                                    .client;

                                final realTimeBloc =
                                    context.read<RealTimeBloc>();
                                for (String userToSend in selectedUsers) {
                                  ChatMessage message = ChatMessage(
                                    from: username,
                                    to: userToSend,
                                    id: generateUniqueString(),
                                    subject: widget.subject,
                                    body: widget.nodeIdentifier,
                                    sendAt: DateTime.now(),
                                  );

                                  bool result =
                                      await client?.sendPayload(message) ??
                                          false;

                                  sending = false;

                                  if (result) {
                                    // fire bloc event
                                    realTimeBloc.add(RealTimeNewMessageEvent(
                                      message: message,
                                      username: username,
                                    ));
                                  } else {
                                    showError(
                                        Constants.websocketNotConnectedError);
                                    return;
                                  }
                                }

                                String successMessage;
                                String messageEnd =
                                    "with $selectedLength user${selectedLength > 1 ? "s" : ""}";
                                switch (widget.subject) {
                                  case MessageSubject.dokiUser:
                                    successMessage =
                                        "Shared @${widget.nodeIdentifier} profile $messageEnd";
                                  case MessageSubject.dokiPost:
                                    successMessage = "Shared post $messageEnd";
                                  case MessageSubject.dokiPage:
                                    successMessage = "Shared page $messageEnd";
                                  case MessageSubject.dokiDiscussion:
                                    successMessage =
                                        "Shared discussion $messageEnd";
                                  case MessageSubject.dokiPolls:
                                    successMessage = "Shared polls $messageEnd";
                                  default:
                                    successMessage = "";
                                }

                                if (successMessage.isNotEmpty) {
                                  showSuccess(successMessage);
                                }
                                if (mounted) contextPop();
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            Constants.buttonWidth,
                            Constants.buttonHeight,
                          ),
                        ),
                        child: Text(sendText),
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

class _ShareUserWidget extends StatelessWidget {
  const _ShareUserWidget({
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
                Column(
                  spacing: Constants.gap * 0.125,
                  children: [
                    UserWidget.nameSmall(
                      userKey: userKey,
                      trim: 12,
                      baseFontSize: Constants.fontSize,
                    ),
                    UserWidget.usernameSmall(
                      userKey: userKey,
                      trim: 12,
                      baseFontSize: Constants.smallFontSize,
                    ),
                  ],
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
