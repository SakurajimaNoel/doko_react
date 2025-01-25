import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/helpers/notifications/notifications_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nice_overlay/nice_overlay.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
        actions: [
          TextButton(
            onPressed: () {
              createOptions();
            },
            child: const Text("Create"),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.userSearch);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.pendingRequests);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: SingleChildScrollView(
          child: Column(
            spacing: Constants.gap * 2,
            children: [
              UserWidget.preview(
                userKey: generateUserNodeKey(username),
              ),
              _ShareDokiItem(),
            ],
          ),
        ),
      ),
    );
  }

  void createOptions() {
    final width = MediaQuery.sizeOf(context).width;
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          height: Constants.height * 15,
          width: width,
          padding: EdgeInsets.all(Constants.padding),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: Constants.gap,
              runSpacing: Constants.gap,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Story"),
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPost);
                  },
                  label: const Text("Post"),
                  icon: const Icon(Icons.add_box_outlined),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Page"),
                  icon: const Icon(Icons.post_add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShareDokiItem extends StatefulWidget {
  const _ShareDokiItem({super.key});

  @override
  State<_ShareDokiItem> createState() => _ShareDokiItemState();
}

class _ShareDokiItemState extends State<_ShareDokiItem> {
  void shareOptions() {
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
            final GetProfileInput details = GetProfileInput(
              username: username,
              currentUsername: username,
            );

            return BlocProvider(
              create: (context) => serviceLocator<ProfileBloc>()
                ..add(GetUserFriendsEvent(
                  userDetails: details,
                )),
              child: _ShareWidget(
                controller: controller,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        shareOptions();
      },
      child: Text("Share"),
    );
  }
}

class _ShareWidget extends StatefulWidget {
  const _ShareWidget({
    required this.controller,
  });

  final ScrollController controller;

  @override
  State<_ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<_ShareWidget> {
  List<String> selectedUsers = [];
  bool loading = false;
  final FocusNode focusNode = FocusNode();
  final UserGraph graph = UserGraph();
  late final String username;
  late final String graphKey;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(handleFocus);
    username = (context.read<UserBloc>().state as UserCompleteState).username;

    graphKey = generateUserNodeKey(username);
  }

  void handleFocus() {
    final viewPortHeight = MediaQuery.sizeOf(context).height;
    if (focusNode.hasFocus) {
      widget.controller.animateTo(
        viewPortHeight,
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(handleFocus);
    focusNode.dispose();
    super.dispose();
  }

  void showInfo(String message) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.normal,
    );

    NiceOverlay.showToast(toast);
  }

  void showError(String message) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.error,
    );

    NiceOverlay.showToast(toast);
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
        context.read<ProfileBloc>().add(LoadMoreProfileFriendsEvent(
              friendDetails: UserProfileNodesInput(
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

    final currTheme = Theme.of(context).colorScheme;

    final userKey = userFriends.items[index];
    final friendUsername = getUsernameFromUserKey(userKey);

    bool isSelected = selectedUsers.contains(friendUsername);
    int selectedLength = selectedUsers.length;

    return Container(
      padding: EdgeInsets.all(Constants.padding * 0.25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius * 0.5),
        color: isSelected
            ? currTheme.primaryContainer.withValues(
                alpha: 0.75,
              )
            : Colors.transparent,
      ),
      child: GestureDetector(
        onTap: () {
          bool selected = selectedUsers.contains(friendUsername);
          if (selected) {
            selectedUsers.remove(friendUsername);
          } else {
            if (selectedLength < Constants.shareLimit) {
              selectedUsers.add(friendUsername);
            } else {
              showInfo(
                  "You can send up to ${Constants.shareLimit} users at a time.");
            }
          }

          setState(() {});
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Constants.gap * 0.5,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserWidget.avtarShare(
              userKey: userKey,
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                color: isSelected
                    ? currTheme.onPrimaryContainer
                    : currTheme.onSurface,
              ),
              child: UserWidget.infoShare(
                userKey: userKey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewPortHeight = MediaQuery.sizeOf(context).height;

    final GetProfileInput details = GetProfileInput(
      username: username,
      currentUsername: username,
    );

    int selectedLength = selectedUsers.length;
    String sendText = selectedUsers.isEmpty
        ? "Send"
        : "Send to $selectedLength user${selectedLength > 1 ? "s" : ""}";

    return Container(
      padding: EdgeInsets.all(Constants.padding),
      width: double.infinity,
      child: Column(
        spacing: Constants.gap * 1.5,
        children: [
          TextField(
            focusNode: focusNode,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Search users by name or username",
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemSize = 105;

              return BlocConsumer<ProfileBloc, ProfileState>(
                listenWhen: (previousState, state) {
                  return state is ProfileFriendLoadResponse;
                },
                listener: (context, state) {
                  loading = false;
                  String errorMessage = "";

                  if (state is ProfileFriendLoadError) {
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
                  final user =
                      graph.getValueByKey(graphKey)! as CompleteUserEntity;
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
                              context
                                  .read<ProfileBloc>()
                                  .add(GetUserProfileEvent(
                                    userDetails: details,
                                  ));
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final user =
                      graph.getValueByKey(graphKey)! as CompleteUserEntity;
                  final Nodes userFriends = user.friends;

                  return GridView.builder(
                    controller: widget.controller,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (width ~/ itemSize),
                      mainAxisSpacing: Constants.gap * 0.5,
                      crossAxisSpacing: Constants.gap * 0.5,
                    ),
                    cacheExtent: viewPortHeight,
                    itemCount: userFriends.items.length + 1,
                    itemBuilder: buildFriendItems,
                  );
                },
              );
            }),
          ),
          SizedBox(
            child: FilledButton(
              onPressed: selectedUsers.isEmpty ? null : () {},
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
      ),
    );
  }
}
