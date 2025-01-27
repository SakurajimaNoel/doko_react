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
  bool viewMore = false;

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
              child: _ArchiveTextBubble(
                body: message.body,
                self: self,
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

class _ArchiveTextBubble extends StatefulWidget {
  const _ArchiveTextBubble({
    required this.body,
    required this.self,
  });

  final String body;
  final bool self;

  @override
  State<_ArchiveTextBubble> createState() => _ArchiveTextBubbleState();
}

class _ArchiveTextBubbleState extends State<_ArchiveTextBubble> {
  bool viewMore = false;
  late final String body = widget.body;
  late final bool self = widget.self;

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

  TextSpan buildMessageBody(String body, bool self) {
    final currTheme = Theme.of(context).colorScheme;

    final matches = <MessageBodyType>[
      ...Constants.emailRegexMessage
          .allMatches(body)
          .map((m) => MessageBodyType(m, "email")),
      ...Constants.urlRegexMessage
          .allMatches(body)
          .map((m) => MessageBodyType(m, "url")),
      ...Constants.phoneRegexMessage
          .allMatches(body)
          .map((m) => MessageBodyType(m, "phone")),
    ]..sort((a, b) {
        // sort result on start index
        return a.match.start <= b.match.start ? -1 : 1;
      });

    // remove duplicate matches
    Set<int> removedMatches = HashSet<int>();
    int lastEnd = -1;

    for (int i = 0; i < matches.length; i++) {
      final current = matches[i];
      if (current.match.start < lastEnd) {
        removedMatches.add(i);
      } else {
        lastEnd = current.match.end;
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

    String displayBody = viewMore
        ? body
        : trimText(
            body,
            len: Constants.messageDisplayLimit,
          );

    bool showButton = body.length > Constants.messageDisplayLimit;
    String buttonText = viewMore ? "View less" : "View More";

    return RichText(
      text: TextSpan(
        children: [
          buildMessageBody(displayBody, self),
          if (showButton)
            TextSpan(
              text: " $buttonText",
              style: TextStyle(
                color: self ? currTheme.primary : currTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: Constants.fontSize,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    viewMore = !viewMore;
                  });
                },
            ),
        ],
      ),
    );
  }
}
