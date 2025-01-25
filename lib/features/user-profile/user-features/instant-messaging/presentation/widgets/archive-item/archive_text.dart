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
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Text(
          str,
          style: style,
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

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: currTheme.shadow.withValues(
                  alpha: 0.25,
                ),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Constants.radius),
            child: BubbleBackground(
              colors: colors,
              child: Column(
                crossAxisAlignment:
                    self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: Constants.padding * 0.75,
                      right: Constants.padding * 0.75,
                      top: Constants.padding * 0.75,
                    ),
                    child: RichText(
                      text: buildMessageBody(message.body, currTheme, self),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Constants.padding * 0.25,
                      horizontal: Constants.padding * 0.75,
                    ),
                    child: Row(
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

@immutable
class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    super.key,
    required this.colors,
    this.child,
  });

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(
        scrollable: Scrollable.of(context),
        bubbleContext: context,
        colors: colors,
      ),
      child: child,
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({
    required ScrollableState scrollable,
    required BuildContext bubbleContext,
    required List<Color> colors,
  })  : _scrollable = scrollable,
        _bubbleContext = bubbleContext,
        _colors = colors,
        super(repaint: scrollable.position);

  final ScrollableState _scrollable;
  final BuildContext _bubbleContext;
  final List<Color> _colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (!_bubbleContext.mounted) return;

    final scrollableBox = _scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = _bubbleContext.findRenderObject() as RenderBox;

    final origin =
        bubbleBox.localToGlobal(Offset.zero, ancestor: scrollableBox);

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        _colors,
        [0.0, 1.0],
        TileMode.clamp,
        Matrix4.translationValues(-origin.dx, -origin.dy, 0.0).storage,
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate._scrollable != _scrollable ||
        oldDelegate._bubbleContext != _bubbleContext ||
        oldDelegate._colors != _colors;
  }
}
