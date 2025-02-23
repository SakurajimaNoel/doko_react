part of "archive_item.dart";

class _ArchiveDiscussion extends StatelessWidget {
  const _ArchiveDiscussion({
    required this.messageKey,
    required this.metaDataStyle,
    required this.bubbleColor,
    required this.textColor,
  });

  final String messageKey;
  final TextStyle metaDataStyle;
  final Color bubbleColor;
  final Color textColor;

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

    Widget type = const Text(
      "DISCUSSION",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: Constants.smallFontSize,
      ),
    );

    return Column(
      spacing: Constants.gap * 0.5,
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Constants.radius),
            color: bubbleColor,
            boxShadow: [
              BoxShadow(
                color: currTheme.shadow.withValues(
                  alpha: 0.25,
                ),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  RouterConstants.userDiscussion,
                  pathParameters: {
                    "discussionId": message.body,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(Constants.padding * 0.5),
                child: DiscussionPreviewWidget(
                  discussionKey: generateDiscussionNodeKey(message.body),
                ),
              ),
            ),
          ),
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
