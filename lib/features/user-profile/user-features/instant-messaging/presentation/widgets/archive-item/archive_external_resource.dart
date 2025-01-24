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

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: Column(
          spacing: Constants.gap * 0.5,
          crossAxisAlignment:
              self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              cacheKey: message.body,
              fit: BoxFit.contain,
              imageUrl: message.body,
              placeholder: (context, url) => SizedBox(
                height: constraints.maxWidth,
                child: Center(
                  child: SmallLoadingIndicator.small(),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              filterQuality: FilterQuality.high,
              memCacheHeight: Constants.archiveMedia,
              width: constraints.maxWidth,
            ),
            Text(
              formatDateTimeToTimeString(message.sendAt),
              style: metaDataStyle,
            ),
          ],
        ),
      );
    });
  }
}
