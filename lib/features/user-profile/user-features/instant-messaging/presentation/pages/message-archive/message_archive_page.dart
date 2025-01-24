import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/archive-item/archive_item.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: UserWidget(
          userKey: generateUserNodeKey(username),
        ),
      ),
      body: BlocBuilder<RealTimeBloc, RealTimeState>(
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

          final archive = graph.getValueByKey(archiveKey)! as ArchiveEntity;
          final messages = archive.currentSessionMessages
              .toList(
                growable: false,
              )
              .reversed
              .toList(
                growable: false,
              );

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding * 0.5,
            ),
            child: ListView.separated(
              reverse: true,
              itemCount: messages.length,
              cacheExtent: height * 2,
              padding: EdgeInsets.all(16),
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 12,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                return buildItem(context, index, messages.toList());
              },
            ),
          );
        },
      ),
    );
  }
}
