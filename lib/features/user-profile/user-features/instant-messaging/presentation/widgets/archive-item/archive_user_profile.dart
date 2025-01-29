part of "archive_item.dart";

class _ArchiveUserProfile extends StatelessWidget {
  const _ArchiveUserProfile({
    required this.messageKey,
    required this.metaDataStyle,
  });

  final String messageKey;
  final TextStyle metaDataStyle;

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    UserGraph graph = UserGraph();
    final MessageEntity entity =
        graph.getValueByKey(messageKey)! as MessageEntity;
    ChatMessage message = entity.message;
    bool self = username == message.from;

    Widget type = const Text(
      "USER PROFILE",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: Constants.smallFontSize,
      ),
    );

    return Column(
      spacing: Constants.gap * 0.5,
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        UserWidget.preview(
          userKey: generateUserNodeKey(message.body),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (self) type,
            Text(
              formatDateTimeToTimeString(message.sendAt),
              style: metaDataStyle,
            ),
            if (!self) type
          ],
        ),
      ],
    );
  }
}
