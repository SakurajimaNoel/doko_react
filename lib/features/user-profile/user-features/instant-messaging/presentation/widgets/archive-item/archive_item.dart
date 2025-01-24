import 'dart:ui' as ui;

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchiveItem extends StatelessWidget {
  const ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
  });

  final String messageKey;
  final bool showDate;

  Widget messageContainer(
      Widget child, BuildContext context, bool self, DateTime sendAt) {
    if (!showDate) return child;

    final currTheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Constants.gap * 0.5,
              horizontal: Constants.gap * 0.75,
            ),
            decoration: BoxDecoration(
              color: currTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(displayDateDifference(sendAt)),
          ),
        ),
        const SizedBox(
          height: Constants.gap * 1.25,
        ),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final messageId = getMessageIdFromMessageKey(messageKey);
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(messageKey)) {
      return SizedBox.shrink();
    }

    MessageEntity messageEntity =
        graph.getValueByKey(messageKey)! as MessageEntity;
    final message = messageEntity.message;
    bool self = message.from == username;

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
    final alignment = self ? Alignment.topRight : Alignment.topLeft;

    Widget child = FractionallySizedBox(
      alignment: alignment,
      widthFactor: 0.8,
      child: Align(
        alignment: alignment,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.all(Radius.circular(Constants.radius)),
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
                    child: Text(message.body),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Text(
                      formatDateTimeToTimeString(message.sendAt),
                      style: TextStyle(
                        fontSize: 12,
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
        ),
      ),
    );

    return messageContainer(child, context, self, message.sendAt);
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
