part of "archive_item.dart";

class _ArchiveExternalResource extends StatelessWidget {
  const _ArchiveExternalResource({
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
      "GIF / STICKER 🖼️",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: Constants.smallFontSize,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          spacing: Constants.gap * 0.5,
          crossAxisAlignment:
              self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.radius),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                cacheKey: message.body,
                fit: BoxFit.contain,
                imageUrl: message.body,
                placeholder: (context, url) => SizedBox(
                  height: constraints.maxWidth,
                  child: const Center(
                    child: SmallLoadingIndicator.small(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                memCacheHeight: Constants.archiveMedia,
                width: constraints.maxWidth,
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
      },
    );
  }
}
