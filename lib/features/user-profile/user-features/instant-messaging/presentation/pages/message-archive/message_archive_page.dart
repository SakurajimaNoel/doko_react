import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/provider/archive_message_provider.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/archive-item/archive_item.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/message-input/message_input.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class MessageArchivePage extends StatefulWidget {
  const MessageArchivePage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<MessageArchivePage> createState() => _MessageArchivePageState();
}

class _MessageArchivePageState extends State<MessageArchivePage> {
  final FocusNode focusNode = FocusNode();
  final ScrollController controller = ScrollController();
  bool show = false;

  late final WebsocketClientProvider websocketClientProvider =
      context.read<WebsocketClientProvider>();

  late ListObserverController observerController;

  final UserGraph graph = UserGraph();
  late final currentUser =
      (context.read<UserBloc>().state as UserCompleteState).username;

  @override
  void initState() {
    super.initState();

    observerController = ListObserverController(
      controller: controller,
    );
    controller.addListener(handleScroll);

    // subscribe to user presence
    final client = websocketClientProvider.client;
    final UserPresenceSubscription subscription = UserPresenceSubscription(
      from: currentUser,
      subscribe: true,
      user: widget.username,
    );

    client?.sendPayload(subscription);
  }

  void handleScroll() {
    final height = MediaQuery.sizeOf(context).height;

    if (controller.offset > height) {
      if (!show) {
        setState(() {
          show = true;
        });
      }
    } else {
      if (show) {
        setState(() {
          show = false;
        });
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.removeListener(handleScroll);
    controller.dispose();

    super.dispose();
  }

  Widget buildItem(BuildContext context, int index, List<String> messages) {
    bool showDate = false;

    /// show date will be true if current message and previous message are not on same day
    if (index == messages.length - 1) {
      showDate = true;
    } else {
      UserGraph graph = UserGraph();
      final currMessage =
          graph.getValueByKey(messages[index])! as MessageEntity;
      final prevMessage =
          graph.getValueByKey(messages[index + 1])! as MessageEntity;

      showDate =
          !areSameDay(currMessage.message.sendAt, prevMessage.message.sendAt);
    }

    String messageKey = messages[index];
    String messageId = getMessageIdFromMessageKey(messageKey);

    final message = graph.getValueByKey(messageKey);
    if (message is MessageEntity) {
      message.listIndex = index;
    }

    return ArchiveItem(
      key: ValueKey(messageId),
      showDate: showDate,
      messageKey: messageKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
      create: (_) => ArchiveMessageProvider(
        focusNode: focusNode,
        selfBackgroundColor: currTheme.primaryContainer,
        selfTextColor: currTheme.onPrimaryContainer,
        backgroundColor: currTheme.surfaceContainerHighest,
        textColor: currTheme.onSurface,
        archiveUser: widget.username,
        controller: observerController,
      ),
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, _) {
              if (didPop) return;

              final archiveMessageProvider =
                  context.read<ArchiveMessageProvider>();
              if (archiveMessageProvider.hasSelection()) {
                archiveMessageProvider.clearSelect();
                return;
              }

              if (focusNode.hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
                return;
              }

              context.pop();
            },
            child: Scaffold(
              floatingActionButtonLocation: const CustomFABLocation(
                offsetY: Constants.height * 2,
              ),
              floatingActionButton: show
                  ? FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        controller.animateTo(
                          0,
                          duration: const Duration(
                            milliseconds: Constants.maxScrollDuration,
                          ),
                          curve: Curves.fastOutSlowIn,
                        );
                      },
                      shape: const CircleBorder(),
                      child: const Icon(Icons.arrow_downward),
                    )
                  : null,
              appBar: AppBar(
                backgroundColor: currTheme.surfaceContainer,
                title: InkWell(
                  onTap: () {
                    context.pushNamed(
                      RouterConstants.messageArchiveProfile,
                      pathParameters: {
                        "username": widget.username,
                      },
                    );
                  },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(
                      text: widget.username,
                    )).then((value) {});
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool shrink = constraints.maxWidth < 150;
                      double shrinkFactor = shrink ? 0.75 : 1;
                      double infoFactor = shrink ? 1 : 0.625;

                      return Row(
                        spacing: Constants.gap * shrinkFactor,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (!shrink)
                            UserWidget.avtar(
                              userKey: generateUserNodeKey(widget.username),
                            ),
                          BlocBuilder<RealTimeBloc, RealTimeState>(
                            buildWhen: (previousState, state) {
                              return state is RealTimeUserPresenceState &&
                                  state.username == widget.username;
                            },
                            builder: (context, state) {
                              bool? online;
                              if (state is RealTimeUserPresenceState &&
                                  state.username == widget.username) {
                                online = state.online;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: Constants.gap * 0.125,
                                children: [
                                  SizedBox(
                                    width: constraints.maxWidth * infoFactor,
                                    child: UserWidget.name(
                                      userKey:
                                          generateUserNodeKey(widget.username),
                                      baseFontSize: Constants.fontSize * 1.125,
                                    ),
                                  ),
                                  if (online != null)
                                    Text(
                                      online ? "Online" : "Offline",
                                      style: TextStyle(
                                        fontSize: Constants.smallFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: online
                                            ? Colors.green
                                            : Colors.redAccent,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: Constants.gap,
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      final selectedMessages = context
                          .watch<ArchiveMessageProvider>()
                          .selectedMessages;

                      if (selectedMessages.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        onPressed: () async {
                          final client =
                              context.read<WebsocketClientProvider>().client;
                          if (client == null) {
                            showError("You are not connected.");
                          }
                          final realTimeBloc = context.read<RealTimeBloc>();
                          final username = (context.read<UserBloc>().state
                                  as UserCompleteState)
                              .username;
                          final archiveMessageProvider =
                              context.read<ArchiveMessageProvider>();

                          DeleteMessage deleteMessage = DeleteMessage(
                            from: username,
                            to: widget.username,
                            id: archiveMessageProvider.selectedMessages.toList(
                              growable: false,
                            ),
                            everyone: false,
                          );

                          bool result =
                              await client!.sendPayload(deleteMessage);
                          if (result) {
                            realTimeBloc.add(RealTimeDeleteMessageEvent(
                              message: deleteMessage,
                              username: username,
                            ));
                            archiveMessageProvider.clearSelect();
                          } else {
                            showError(
                                "Failed to delete ${archiveMessageProvider.selectedMessages.length} messages.");
                          }
                        },
                        color: currTheme.error,
                        icon: Badge(
                          label: Text(selectedMessages.length.toString()),
                          child: const Icon(Icons.delete_forever),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BlocBuilder<RealTimeBloc, RealTimeState>(
                      buildWhen: (previousState, state) {
                        return (state is RealTimeNewMessageState &&
                                state.archiveUser == widget.username) ||
                            (state is RealTimeDeleteMessageState &&
                                state.archiveUser == widget.username);
                      },
                      builder: (context, state) {
                        final UserGraph graph = UserGraph();
                        String archiveKey = generateArchiveKey(widget.username);
                        String inboxKey = generateInboxItemKey(widget.username);

                        if (!graph.containsKey(archiveKey)) {
                          // check inbox if elements are present and show them before fetching archive messaging
                          return const SizedBox.shrink();
                        }

                        final archive =
                            graph.getValueByKey(archiveKey)! as ArchiveEntity;
                        final messages = archive.currentSessionMessages
                            .toList(
                              growable: false,
                            )
                            .reversed
                            .toList(
                              growable: false,
                            );
                        return ListViewObserver(
                          controller: observerController,
                          child: ListView.separated(
                            controller: controller,
                            reverse: true,
                            itemCount: messages.length,
                            cacheExtent: height * 2,
                            padding: const EdgeInsets.only(
                              top: Constants.padding * 2,
                              bottom: Constants.padding * 1,
                            ),
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: Constants.gap * 0.5,
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return buildItem(
                                  context, index, messages.toList());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  MessageInput(
                    archiveUser: widget.username,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomFABLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const CustomFABLocation({this.offsetY = 16}); // Default: move up by 16 pixels

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standard =
        FloatingActionButtonLocation.endTop.getOffset(scaffoldGeometry);
    return Offset(standard.dx, standard.dy + offsetY);
  }
}
