import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/provider/bottom-nav/bottom_nav_provider.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/instant-messaging/message_preview.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'bloc/real-time/real_time_bloc.dart';
import 'bloc/user-action/user_action_bloc.dart';

class UserLayout extends StatefulWidget {
  const UserLayout(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  late int activeIndex;
  late final Client client;

  bool isForeground = true;
  DateTime? backgroundWhen;

  late StreamSubscription<FGBGType> appState;
  AsyncCallback? retryOnForeground;

  @override
  void initState() {
    super.initState();

    activeIndex = widget.navigationShell.currentIndex;

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final connectionChecker = InternetConnectionChecker.instance;
    appState = FGBGEvents.instance.stream.listen((event) {
      isForeground = event == FGBGType.foreground;

      if (!isForeground) {
        /// refresh whole app if user comes back after [Constants.backgroundDurationLimit]
        backgroundWhen = DateTime.now();
      } else {
        /// process event if on foreground
        if (retryOnForeground != null) {
          retryOnForeground!();
          retryOnForeground = null;
        }

        DateTime now = DateTime.now();
        if (backgroundWhen == null) return;

        Duration diff = now.difference(backgroundWhen!);
        backgroundWhen = null;

        /// refresh the whole app after [Constants.backgroundDurationLimit]
        if (diff.inMinutes > Constants.backgroundDurationLimit) {
          refreshApp();
        }
      }
    });

    final realTimeBloc = context.read<RealTimeBloc>();
    final userToUserActionBloc = context.read<UserToUserActionBloc>();

    // create websocket client
    client = Client(
      url: Uri.parse(dotenv.env["WEBSOCKET_ENDPOINT"]!),
      pingInterval: Constants.pingInterval,
      getToken: () async {
        final token = await getUserToken();
        return token.idToken;
      },
      onReconnectSuccess: () {
        /// find latest message from inbox and fetch based on that
        showSuccess("Reconnected to websocket server.");
      },
      onConnectionClosure: (retry) async {
        StreamSubscription<InternetConnectionStatus>? internetSubscription;

        void cancelSubscriptions() {
          internetSubscription?.cancel();
        }

        Future<void> handleReconnection() async {
          bool isConnected = await connectionChecker.hasConnection;
          if (isConnected) {
            retry();
            cancelSubscriptions();
          } else {
            showError("No internet connection.");

            // Listen for internet connection changes
            internetSubscription = connectionChecker.onStatusChange.listen(
              (InternetConnectionStatus status) {
                if (status == InternetConnectionStatus.connected) {
                  retry();
                  cancelSubscriptions();
                }
              },
            );
          }
        }

        if (isForeground) {
          await handleReconnection();
        } else {
          retryOnForeground = handleReconnection;
        }
      },
      payloadHandler: {
        PayloadType.chatMessage: (ChatMessage message) {
          String remoteUser = getUsernameFromMessageParams(
            username,
            to: message.to,
            from: message.from,
          );

          if (remoteUser == message.from && username != remoteUser) {
            showNewMessageNotification(
                message, generateUserNodeKey(message.from));
          }

          realTimeBloc.add(RealTimeNewMessageEvent(
            message: message,
            username: username,
          ));
        },
        PayloadType.typingStatus: (TypingStatus status) {
          realTimeBloc.add(RealTimeTypingStatusEvent(
            status: status,
          ));
        },
        PayloadType.editMessage: (EditMessage message) {
          realTimeBloc.add(RealTimeEditMessageEvent(
            message: message,
            username: username,
          ));
        },
        PayloadType.deleteMessage: (DeleteMessage message) {
          realTimeBloc.add(RealTimeDeleteMessageEvent(
            message: message,
            username: username,
          ));
        },
        PayloadType.userSendFriendRequest: (UserSendFriendRequest request) {
          if (request.to == username) {
            showNewFriendRequestNotification(request);
          }

          userToUserActionBloc
              .add(UserToUserActionUserSendFriendRequestRemoteEvent(
            username: username,
            request: request,
          ));
        },
        PayloadType.userAcceptFriendRequest: (UserAcceptFriendRequest request) {
          if (request.to == username) {
            showAcceptedFriendNotification(request);
          }

          userToUserActionBloc
              .add(UserToUserActionUserAcceptsFriendRequestRemoteEvent(
            username: username,
            request: request,
          ));
        },
        PayloadType.userRemovesFriendRelation:
            (UserRemovesFriendRelation relation) {
          userToUserActionBloc
              .add(UserToUserActionUserRemovesFriendRelationRemoteEvent(
            username: username,
            relation: relation,
          ));
        },
        PayloadType.userUpdateProfile: (UserUpdateProfile payload) {
          context
              .read<UserToUserActionBloc>()
              .add(UserToUserUpdateProfileRemoteEvent(
                username: payload.from,
                name: payload.name,
                bio: payload.bio,
                profilePicture: payload.profilePicture,
              ));
        },
        PayloadType.userCreateRootNode: (UserCreateRootNode payload) {
          if (payload.nodeType == NodeType.post) {
            context.read<UserActionBloc>().add(UserActionNewPostRemoteEvent(
                  postId: payload.id,
                  username: username,
                ));
          }
        },
        PayloadType.userNodeLikeAction: (UserNodeLikeAction payload) {
          // handle notification
          if (payload.from != username) {
            // show notification
          }
          context.read<UserActionBloc>().add(UserActionNodeLikeRemoteEvent(
                payload: payload,
                username: username,
              ));
        }
      },
    );

    connectWS();
  }

  void refreshApp() {
    context.read<UserBloc>().add(UserInitEvent());
  }

  Future<void> connectWS() async {
    final websocketClientProvider = context.read<WebsocketClientProvider>();
    await client.connect();

    showSuccess("Connected to websocket server.");
    websocketClientProvider.addClient(client);
  }

  void showUserLikeMyNodeNotification(UserNodeLikeAction payload) {
    final userKey = generateUserNodeKey(payload.from);
    final notification = createNewNotification(
        context: context,
        userKey: userKey,
        body: Text("@${payload.from} liked your ${payload.nodeType.name}."),
        onTap: () {
          if (payload.nodeType == NodeType.post) {
            // go to post page
            context.pushNamed(RouterConstants.userPost, pathParameters: {
              "postId": payload.nodeId,
            });
          }

          if (payload.nodeType == NodeType.comment) {
            bool commentReply = payload.parents.length == 3;
            String parentNodeType =
                DokiNodeType.fromNodeType(payload.parents.first.nodeType).name;
            String parentNodeId = payload.parents.first.nodeId;

            String rootNodeType = parentNodeType;
            String rootNodeId = parentNodeId;
            if (commentReply) {
              rootNodeType =
                  DokiNodeType.fromNodeType(payload.parents[1].nodeType).name;
              rootNodeId = payload.parents[1].nodeId;
            }

            context.pushNamed(
              RouterConstants.comment,
              pathParameters: {
                "userId": payload.parents.last.nodeId,
                "parentNodeType": parentNodeType,
                "parentNodeId": parentNodeId,
                "commentId": payload.nodeId,
                "rootNodeType": rootNodeType,
                "rootNodeId": rootNodeId,
              },
            );
          }
        });

    showNotification(notification);
  }

  void showNewFriendRequestNotification(UserSendFriendRequest request) {
    final userKey = generateUserNodeKey(request.from);
    final notification = createNewNotification(
      context: context,
      userKey: userKey,
      notificationTime: request.addedOn,
      body: Text("@${request.from} has send you a friend request."),
      onTap: () {
        context.pushNamed(
          RouterConstants.userProfile,
          pathParameters: {
            "username": getUsernameFromUserKey(userKey),
          },
        );
      },
    );

    showNotification(notification);
  }

  void showAcceptedFriendNotification(UserAcceptFriendRequest request) {
    final userKey = generateUserNodeKey(request.from);
    final notification = createNewNotification(
      context: context,
      userKey: userKey,
      body: Text("@${request.from} has accepted your friend request."),
      onTap: () {
        context.pushNamed(
          RouterConstants.userProfile,
          pathParameters: {
            "username": getUsernameFromUserKey(userKey),
          },
        );
      },
    );

    showNotification(notification);
  }

  void showNewMessageNotification(ChatMessage message, String userKey) {
    final String routeName = GoRouter.of(context).currentRouteName ?? "";
    final Map<String, String> pathParams =
        GoRouter.of(context).currentRoutePathParameters;
    if (routeName == RouterConstants.messageArchive &&
        pathParams["username"] == getUsernameFromUserKey(userKey)) {
      // gentle remainder
      HapticFeedback.vibrate();
      return;
    }

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final inAppNotification = createNewNotification(
      userKey: userKey,
      notificationTime: message.sendAt,
      body: Text(messagePreview(message, username)),
      onTap: () {
        context.pushNamed(
          RouterConstants.messageArchive,
          pathParameters: {
            "username": getUsernameFromUserKey(userKey),
          },
        );
      },
      context: context,
    );

    showNotification(inAppNotification);
  }

  @override
  void dispose() {
    appState.cancel();
    client.disconnect();
    super.dispose();
  }

  List<Widget> getDestinations(UserEntity user) {
    final currTheme = Theme.of(context).colorScheme;

    return [
      NavigationDestination(
        selectedIcon: Icon(
          Icons.home,
          color: currTheme.onPrimary,
        ),
        icon: const Icon(Icons.home_outlined),
        label: "Home",
      ),
      NavigationDestination(
        selectedIcon: Icon(
          Icons.broadcast_on_personal,
          color: currTheme.onPrimary,
        ),
        icon: const Icon(Icons.broadcast_on_personal_outlined),
        label: "Nearby",
      ),
      NavigationDestination(
        selectedIcon: user.profilePicture.bucketPath.isEmpty
            ? Icon(
                Icons.account_circle,
                color: currTheme.onPrimary,
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: currTheme.primary,
                child: CircleAvatar(
                  radius: 17,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      cacheKey: user.profilePicture.bucketPath,
                      imageUrl: user.profilePicture.accessURI,
                      placeholder: (context, url) => const Center(
                        child: SmallLoadingIndicator.small(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      memCacheHeight: Constants.thumbnailCacheHeight,
                    ),
                  ),
                ),
              ),
        icon: user.profilePicture.bucketPath.isEmpty
            ? const Icon(Icons.account_circle_outlined)
            : CircleAvatar(
                radius: 20,
                backgroundColor: currTheme.primary,
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      cacheKey: user.profilePicture.bucketPath,
                      imageUrl: user.profilePicture.accessURI,
                      placeholder: (context, url) => const Center(
                        child: SmallLoadingIndicator.small(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      memCacheHeight: Constants.thumbnailCacheHeight,
                    ),
                  ),
                ),
              ),
        label: trimText(
          user.name,
          len: 16,
        ),
        tooltip: user.name,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final currTheme = Theme.of(context).colorScheme;

    return BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
      buildWhen: (previousState, state) {
        return state is UserToUserActionUpdateProfileState &&
            state.username == username;
      },
      builder: (context, state) {
        String key = generateUserNodeKey(username);

        final UserGraph graph = UserGraph();
        UserEntity user = graph.getValueByKey(key)! as UserEntity;
        bool profileEmpty = user.profilePicture.bucketPath.isEmpty;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) {
            /// this handles going to user feed page
            /// when in one of the other pages of
            /// stateful shell route
            if (didPop) return;

            if (activeIndex == 0) {
              SystemNavigator.pop();
              return;
            }

            context.read<BottomNavProvider>().showBottomNav();
            onDestinationSelected(0, profileEmpty);
          },
          child: Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: Builder(builder: (context) {
              bool show = context.watch<BottomNavProvider>().show;

              return show
                  ? NavigationBar(
                      indicatorColor: (activeIndex != 2 || profileEmpty)
                          ? currTheme.primary
                          : Colors.transparent,
                      selectedIndex: widget.navigationShell.currentIndex,
                      destinations: getDestinations(user),
                      onDestinationSelected: (index) =>
                          onDestinationSelected(index, profileEmpty),
                    )
                  : const SizedBox.shrink();
            }),
          ),
        );
      },
    );
  }

  void onDestinationSelected(int index, bool profileEmpty) {
    int prevIndex = widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (prevIndex == 2 && !profileEmpty) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          setState(() {
            activeIndex = index;
          });
        },
      );
    } else {
      setState(() {
        activeIndex = index;
      });
    }
  }
}
