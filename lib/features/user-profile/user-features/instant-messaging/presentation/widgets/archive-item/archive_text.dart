part of "archive_item.dart";

/// [_ArchiveText] handles message payload with subject [MessageSubject.text]
class _ArchiveText extends StatefulWidget {
  const _ArchiveText({
    required this.messageKey,
  });

  final String messageKey;

  @override
  State<_ArchiveText> createState() => _ArchiveTextState();
}

class _ArchiveTextState extends State<_ArchiveText> {
  int highLightIndex = -1;

  TextSpan buildText(
    String str, {
    TextStyle? style,
    GestureRecognizer? recognizer,
  }) {
    return TextSpan(
      text: str,
      style: style,
      recognizer: recognizer,
    );
  }

  void resetHighlight() {
    Timer(
        Duration(
          milliseconds: 500,
        ), () {
      if (mounted) {
        setState(() {
          highLightIndex = -1;
        });
      }
    });
  }

  // todo improve this
  TextSpan buildMessageBody(String body, ColorScheme currScheme) {
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
    final children = <TextSpan>[];

    for (int i = 0; i < validMatches.length; i++) {
      final highlightMatch = validMatches[i];

      final match = highlightMatch.match;
      final String type = highlightMatch.type;

      int start = match.start;
      int end = match.end;

      final String normalText = body.substring(startIndex, start);
      final String highlightText = body.substring(start, end);

      startIndex = end;

      final TextStyle highlightStyle = TextStyle(
        color: currScheme.primary,
        fontWeight: FontWeight.w500,
        wordSpacing: 5,
        backgroundColor:
            highLightIndex == i ? currScheme.onPrimary : Colors.transparent,
      );

      children.add(buildText(normalText));
      children.add(
        buildText(
          highlightText,
          style: highlightStyle,
          recognizer: LongPressGestureRecognizer()
            ..onLongPress = () {
              setState(() {
                highLightIndex = i;
              });
              // resetHighlight();

              HapticFeedback.vibrate();
              Clipboard.setData(ClipboardData(
                text: highlightText,
              )).then((value) {});
            }
            ..onLongPressCancel = () {
              setState(() {
                highLightIndex = i;
              });
              resetHighlight();

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
            }
            ..onLongPressEnd = (_) {
              resetHighlight();
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
        return (state is RealTimeEditMessageState && state.id == messageId) ||
            (state is RealTimeDeleteMessageState &&
                state.id.contains(messageId));
      },
      builder: (context, state) {
        UserGraph graph = UserGraph();
        final MessageEntity entity =
            graph.getValueByKey(widget.messageKey)! as MessageEntity;
        ChatMessage message = entity.message;
        bool self = message.from == username;

        /// full screen gradient color for chat message [https://docs.flutter.dev/cookbook/effects/gradient-bubbles]
        /// reference above cookbook for more info about gradient effect
        List<Color> colors = self
            ? [
                currTheme.primaryContainer.withBlue(50),
                currTheme.primaryContainer,
              ]
            : [
                currTheme.secondaryContainer.withBlue(50),
                currTheme.secondaryContainer,
              ];

        TextStyle textStyle = TextStyle(
          color: self ? currTheme.onPrimaryContainer : currTheme.onSurface,
          fontSize: Constants.fontSize,
        );

        return ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(
              Constants.radius,
            ),
          ),
          child: BubbleBackground(
            colors: colors,
            child: DefaultTextStyle.merge(
              style: textStyle,
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
                      text: buildMessageBody(message.body, currTheme),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Constants.padding * 0.25,
                      horizontal: Constants.padding * 0.75,
                    ),
                    child: Text(
                      formatDateTimeToTimeString(message.sendAt),
                      style: TextStyle(
                        fontSize: Constants.smallFontSize,
                        fontWeight: FontWeight.w600,
                        color: self
                            ? currTheme.onPrimaryContainer.withValues(
                                alpha: 0.5,
                              )
                            : currTheme.onSecondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                      ),
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
