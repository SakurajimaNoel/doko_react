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
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    UserGraph graph = UserGraph();
    final MessageEntity entity =
        graph.getValueByKey(messageKey)! as MessageEntity;
    ChatMessage message = entity.message;
    bool self = username == message.from;

    Widget type = Text(
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
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: currTheme.onSurface,
              fontSize: Constants.fontSize * 0.9,
              letterSpacing: 0.75,
            ),
            text: "User profile shared: ",
            children: [
              TextSpan(
                text: "@${message.body}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
