import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeActionWidget extends StatefulWidget {
  const SwipeActionWidget({
    super.key,
    required this.onSwipeSuccess,
    required this.child,
  });

  final VoidCallback onSwipeSuccess;
  final Widget child;

  @override
  State<SwipeActionWidget> createState() => _SwipeActionWidgetState();
}

class _SwipeActionWidgetState extends State<SwipeActionWidget>
    with SingleTickerProviderStateMixin {
  late final VoidCallback onSwipeSuccess;

  double start = 0;
  double left = 0;

  bool dragging = false;
  bool shouldCallOnEnd = false;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
    );

    controller.addListener(updateLeftValue);
  }

  void updateLeftValue() {
    setState(() {
      left = animation.value;
    });
  }

  void handleCrossThreshold() {
    if (shouldCallOnEnd) return;
    shouldCallOnEnd = true;
    HapticFeedback.vibrate();
  }

  void onDragEnd() {
    if (shouldCallOnEnd) {
      widget.onSwipeSuccess();
    }

    dragging = false;
    shouldCallOnEnd = false;

    start = 0;

    animation = Tween<double>(begin: left, end: 0).animate(controller);
    controller.forward(
      from: 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var offset = MediaQuery.sizeOf(context).width / 4;
    const double minLimit = 150;
    if (offset < minLimit) {
      offset = minLimit;
    }

    return Transform.translate(
      offset: Offset(left, 0),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          controller.stop();
          start = details.localPosition.dx;
          dragging = true;
        },
        onHorizontalDragUpdate: (details) {
          if (!dragging) return;

          left = details.localPosition.dx;
          left -= start;

          if (left < 0) left = 0;
          setState(() {});

          if (left > offset) {
            handleCrossThreshold();
          } else {
            shouldCallOnEnd = false;
          }
        },
        onHorizontalDragEnd: (details) {
          onDragEnd();
        },
        child: widget.child,
      ),
    );
  }
}
