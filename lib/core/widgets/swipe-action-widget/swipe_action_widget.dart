import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SwipeDirection {
  left,
  right,
}

class SwipeActionWidget extends StatefulWidget {
  const SwipeActionWidget({
    super.key,
    required this.onSwipeSuccess,
    required this.child,
    this.swipeDirection = SwipeDirection.left,
  });

  final VoidCallback onSwipeSuccess;
  final Widget child;
  final SwipeDirection swipeDirection;

  @override
  State<SwipeActionWidget> createState() => _SwipeActionWidgetState();
}

class _SwipeActionWidgetState extends State<SwipeActionWidget>
    with SingleTickerProviderStateMixin {
  late final VoidCallback onSwipeSuccess;

  double start = 0;
  double offsetX = 0;

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
      offsetX = animation.value;
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

    animation = Tween<double>(begin: offsetX, end: 0).animate(controller);
    controller.forward(
      from: 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isInvalidOffsetX(double offsetX) {
    if (widget.swipeDirection == SwipeDirection.left) {
      return offsetX < 0;
    }
    return offsetX > 0;
  }

  @override
  Widget build(BuildContext context) {
    var threshold = MediaQuery.sizeOf(context).width / 4;
    const double minLimit = 100;
    if (threshold < minLimit) {
      threshold = minLimit;
    }

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          controller.stop();
          start = details.localPosition.dx;
          dragging = true;
        },
        onHorizontalDragUpdate: (details) {
          if (!dragging) return;

          offsetX = details.localPosition.dx;
          offsetX -= start;

          if (isInvalidOffsetX(offsetX)) offsetX = 0;
          setState(() {});

          if (offsetX.abs() > threshold) {
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
