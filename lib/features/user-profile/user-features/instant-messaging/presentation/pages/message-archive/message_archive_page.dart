import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/archive-item/archive_item.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/message-input/message_input.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageArchivePage extends StatelessWidget {
  const MessageArchivePage({
    super.key,
    required this.username,
  });

  final String username;

  Widget buildItem(BuildContext context, int index, List<String> messages) {
    bool trial = false;
    if (index == messages.length - 1) trial = true;
    return ArchiveItem(
      showDate: trial,
      messageKey: messages[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: currTheme.surfaceContainer,
        title: InkWell(
          onTap: () {
            context.pushNamed(
              RouterConstants.messageArchiveProfile,
              pathParameters: {
                "username": username,
              },
            );
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(
              text: username,
            )).then((value) {});
          },
          child: Row(
            spacing: Constants.gap,
            children: [
              UserWidget.avtar(
                userKey: generateUserNodeKey(username),
              ),
              UserWidget.info(
                userKey: generateUserNodeKey(username),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: BlocBuilder<RealTimeBloc, RealTimeState>(
              buildWhen: (previousState, state) {
                return state is RealTimeNewMessageState &&
                    state.archiveUser == username;
              },
              builder: (context, state) {
                final UserGraph graph = UserGraph();
                String archiveKey = generateArchiveKey(username);
                String inboxKey = generateInboxItemKey(username);

                if (!graph.containsKey(archiveKey)) {
                  // check inbox if elements are present and show them before fetching archive messaging
                  return SizedBox.shrink();
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
                return ListView.separated(
                  reverse: true,
                  itemCount: messages.length,
                  cacheExtent: height * 2,
                  padding: EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                      vertical: Constants.padding * 2),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: Constants.gap * 1.5,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return buildItem(context, index, messages.toList());
                  },
                );
              },
            ),
          ),
          MessageInput(
            archiveUser: username,
          ),
        ],
      ),
    );
  }
}
