part of "archive_item.dart";

/// [_ArchiveText] handles message payload with subject [MessageSubject.text]
class _ArchiveText extends StatefulWidget {
  const _ArchiveText({
    required this.messageKey,
    required this.metaDataStyle,
    required this.colors,
  });

  final String messageKey;
  final TextStyle metaDataStyle;
  final List<Color> colors;

  @override
  State<_ArchiveText> createState() => _ArchiveTextState();
}

class _ArchiveTextState extends State<_ArchiveText> {
  late final List<Color> colors = widget.colors;

  InlineSpan buildText(
    String str, {
    TextStyle? style,
    VoidCallback? onLongPress,
    VoidCallback? onTap,
  }) {
    if (onLongPress == null || onTap == null) {
      return TextSpan(
        text: str,
        style: style,
      );
    }

    return WidgetSpan(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          onTap: onTap,
          child: Text(
            str,
            style: style,
          ),
        ),
      ),
    );
  }

  // todo improve this
  TextSpan buildMessageBody(String body, ColorScheme currTheme, bool self) {
    final RegExp emailRegex =
        RegExp(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
    final RegExp urlRegex = RegExp(
        r"(?!@)(https?:\/\/)?([a-zA-Z0-9-]+\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}([\/\w\-\.~]*)?(\?[^\s#@]*)?(\#[^\s@]*)?");
    final RegExp phoneRegex = RegExp(
        r"(\+?[0-9]{1,3})?[ ]?[0-9]{3}[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}");

    final matches = <MessageBodyType>[
      ...emailRegex.allMatches(body).map((m) => MessageBodyType(m, "email")),
      ...urlRegex.allMatches(body).map((m) => MessageBodyType(m, "url")),
      ...phoneRegex.allMatches(body).map((m) => MessageBodyType(m, "phone")),
    ]..sort((a, b) {
        return a.match.start <= b.match.start ? -1 : 1;
      });

    Set<int> removedMatches = HashSet<int>();
    for (int i = 0; i < matches.length; i++) {
      if (removedMatches.contains(i)) continue;
      final first = matches[i];
      for (int j = i + 1; j < matches.length; j++) {
        if (removedMatches.contains(j)) continue;

        final second = matches[j];

        if (first.match.end >= second.match.start) removedMatches.add(j);
      }
    }

    List<MessageBodyType> validMatches = [];
    for (int i = 0; i < matches.length; i++) {
      if (removedMatches.contains(i)) continue;
      validMatches.add(matches[i]);
    }

    int startIndex = 0;
    final children = <InlineSpan>[];

    final TextStyle highlightStyle = TextStyle(
      color: currTheme.primary,
      fontWeight: FontWeight.w500,
      wordSpacing: 5,
    );

    for (int i = 0; i < validMatches.length; i++) {
      final highlightMatch = validMatches[i];

      final match = highlightMatch.match;
      final String type = highlightMatch.type;

      int start = match.start;
      int end = match.end;

      final String normalText = body.substring(startIndex, start);
      final String highlightText = body.substring(start, end);

      startIndex = end;

      children.add(buildText(normalText));
      children.add(
        buildText(
          highlightText,
          style: highlightStyle,
          onLongPress: () {
            Clipboard.setData(ClipboardData(
              text: highlightText,
            )).then((value) {});
          },
          onTap: () {
            if (type == "email") {
              final emailUri = Uri(scheme: "mailto", path: highlightText);
              launchUrl(emailUri);
            } else if (type == "url") {
              final urlUri = Uri.parse(highlightText.startsWith('http')
                  ? highlightText
                  : 'http://$highlightText');
              launchUrl(urlUri);
            } else if (type == "phone") {
              final phoneUri = Uri(scheme: "tel", path: highlightText);
              launchUrl(phoneUri);
            }
          },
        ),
      );
    }
    final String remainingText = body.substring(startIndex);
    children.add(buildText(remainingText));

    return TextSpan(
      style: TextStyle(
        height: 1.25,
        wordSpacing: 1.25,
        fontSize: Constants.fontSize,
        color: self ? currTheme.onPrimaryContainer : currTheme.onSurface,
      ),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final String messageId = getMessageIdFromMessageKey(widget.messageKey);
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocBuilder<RealTimeBloc, RealTimeState>(
      buildWhen: (previousState, state) {
        return (state is RealTimeEditMessageState && state.id == messageId);
      },
      builder: (context, state) {
        UserGraph graph = UserGraph();
        final MessageEntity entity =
            graph.getValueByKey(widget.messageKey)! as MessageEntity;
        ChatMessage message = entity.message;
        bool self = message.from == username;

        return Column(
          spacing: Constants.gap * 0.5,
          crossAxisAlignment:
              self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.radius),
                color: colors.last,
                boxShadow: [
                  BoxShadow(
                    color: currTheme.shadow.withValues(
                      alpha: 0.25,
                    ),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(
                Constants.padding * 0.75,
              ),
              child: RichText(
                text: buildMessageBody(message.body, currTheme, self),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Constants.gap * 1.5,
              children: [
                Text(
                  formatDateTimeToTimeString(message.sendAt),
                  style: widget.metaDataStyle,
                ),
                if (entity.edited)
                  Text(
                    "edited",
                    style: widget.metaDataStyle,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
