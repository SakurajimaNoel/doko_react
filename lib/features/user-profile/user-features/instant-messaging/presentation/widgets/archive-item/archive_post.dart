part of "archive_item.dart";

class _ArchivePost extends StatelessWidget {
  const _ArchivePost({
    required this.messageKey,
    required this.metaDataStyle,
    required this.colors,
  });

  final String messageKey;
  final TextStyle metaDataStyle;
  final List<Color> colors;

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

    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(
          Constants.radius,
        ),
      ),
      child: BubbleBackground(
        colors: colors,
        child: Container(
          padding: EdgeInsets.all(Constants.padding * 0.5),
          child: Column(
            spacing: Constants.gap * 0.5,
            crossAxisAlignment:
                self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              PostPreviewWidget(
                postKey: generatePostNodeKey(message.body),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(
                      RouterConstants.userPost,
                      pathParameters: {
                        "postId": message.body,
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.padding * 0.5,
                      vertical: Constants.padding * 0.25,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(
                      color: currTheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: Constants.fontSize * 0.85,
                    ),
                  ),
                  child: Text("Go to post"),
                ),
              ),
              Text(
                formatDateTimeToTimeString(message.sendAt),
                style: metaDataStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
