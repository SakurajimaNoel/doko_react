import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/bottom-nav/bottom_nav_provider.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/helpers/extension/go_router_extension.dart';
import 'package:doko_react/core/helpers/notifications/notifications_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nice_overlay/nice_overlay.dart';
import 'package:provider/provider.dart';

import 'bloc/real-time/real_time_bloc.dart';

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
        /// refresh whole app if user comes back after 30minutes
        backgroundWhen = DateTime.now();
      } else {
        DateTime now = DateTime.now();
        if (backgroundWhen == null) return;

        Duration diff = now.difference(backgroundWhen!);
        backgroundWhen = null;

        if (diff.inMinutes > 30) {
          refreshApp();
        }
      }
    });

    final realTimeBloc = context.read<RealTimeBloc>();
    final UserGraph graph = UserGraph();

    // create websocket client
    client = Client(
      url: Uri.parse(dotenv.env["WEBSOCKET_ENDPOINT"]!),
      getToken: () async {
        final token = await getUserToken();
        return token.idToken;
      },
      onChatMessageReceived: (ChatMessage message) {
        String remoteUser = getUsernameFromMessageParams(
          username,
          to: message.to,
          from: message.from,
        );

        if (!graph.containsKey(generateUserNodeKey(remoteUser))) {
          context.read<UserActionBloc>().add(UserActionGetUserByUsernameEvent(
                username: remoteUser,
                currentUser: username,
              ));
        }

        showNewMessageNotification(message, generateUserNodeKey(remoteUser));
        realTimeBloc.add(RealTimeNewMessageEvent(
          message: message,
          username: username,
        ));
      },
      onTypingStatusReceived: (TypingStatus status) {
        realTimeBloc.add(RealTimeTypingStatusEvent(
          status: status,
        ));
      },
      onEditMessageReceived: (EditMessage message) {
        realTimeBloc.add(RealTimeEditMessageEvent(
          message: message,
          username: username,
        ));
      },
      onDeleteMessageReceived: (DeleteMessage message) {
        realTimeBloc.add(RealTimeDeleteMessageEvent(
          message: message,
          username: username,
        ));
      },
      onReconnectSuccess: () {
        /// find latest message from inbox and fetch based on that
      },
      onConnectionClosure: (retry) async {
        StreamSubscription<FGBGType>? fgBgSubscription;
        StreamSubscription<InternetConnectionStatus>? internetSubscription;

        void cancelSubscriptions() {
          internetSubscription?.cancel();
          fgBgSubscription?.cancel();
        }

        Future<void> handleReconnection() async {
          bool isConnected = await connectionChecker.hasConnection;
          if (isConnected) {
            showMessage("App has internet connection");

            retry();
            cancelSubscriptions();
          } else {
            // Listen for internet connection changes
            internetSubscription = connectionChecker.onStatusChange.listen(
              (InternetConnectionStatus status) {
                if (status == InternetConnectionStatus.connected) {
                  showMessage("App has internet connection");

                  retry();
                  cancelSubscriptions();
                }
              },
            );
          }
        }

        if (isForeground) {
          showMessage("App is in foreground");
          await handleReconnection();
        } else {
          fgBgSubscription = FGBGEvents.instance.stream.listen(
            (event) async {
              if (event == FGBGType.foreground) {
                showMessage("App is in foreground");
                await handleReconnection();
              }
            },
          );
        }
      },
    );

    connectWS();
  }

  void refreshApp() {
    context.read<UserBloc>().add(UserInitEvent());
  }

  Future<void> connectWS() async {
    await client.connect();
    showMessage("connected to websocket server");
  }

  void showNewMessageNotification(ChatMessage message, String userKey) {
    final String routeName = GoRouter.of(context).currentRouteName ?? "";
    final Map<String, String> pathParams =
        GoRouter.of(context).currentRoutePathParameters;
    if (routeName == RouterConstants.messageArchive &&
        pathParams["username"] == getUsernameFromUserKey(userKey)) {
      return;
    }

    final inAppNotification = createNewNotification(
      leading: UserWidget.avtar(
        userKey: userKey,
      ),
      title: UserWidget.infoSmall(
        userKey: userKey,
      ),
      body: Text(trimText(message.body)),
      trailing: Text(
        displayDateDifference(message.sendAt),
        style: TextStyle(
          fontSize: Constants.smallFontSize,
        ),
      ),
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

    NiceOverlay.showInAppNotification(inAppNotification);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
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
    final currTheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider<WebsocketClientProvider>(
      create: (_) => WebsocketClientProvider(
        client: client,
      ),
      child: BlocBuilder<UserActionBloc, UserActionState>(
        buildWhen: (previousState, state) {
          return state is UserActionUpdateProfile;
        },
        builder: (context, state) {
          final username =
              (context.read<UserBloc>().state as UserCompleteState).username;
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
                    : SizedBox.shrink();
              }),
            ),
          );
        },
      ),
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
