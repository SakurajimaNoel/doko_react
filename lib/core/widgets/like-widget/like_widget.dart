import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LikeWidget extends StatefulWidget {
  const LikeWidget({
    super.key,
    required this.onPress,
    required this.userLike,
    this.shrinkFactor = 1,
  });

  final VoidCallback onPress;
  final bool userLike;
  final double shrinkFactor;

  @override
  State<LikeWidget> createState() => LikeWidgetState();
}

class LikeWidgetState extends State<LikeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    )..value = widget.userLike
        ? 1
        : 0; // when first render show the correct state of user like
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final color = currTheme.primary;

    /// after user like status is changed
    /// update animation from here in order to sync
    /// with all the widgets that share the same node
    if (widget.userLike) {
      controller.forward();
    } else {
      controller.reset();
    }

    return IconButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.all(Constants.padding * 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        // just handle feedback here
        if (!widget.userLike) {
          HapticFeedback.vibrate();
          SystemSound.play(SystemSoundType.click);
        }
        widget.onPress();
      },
      icon: Lottie.asset(
        "assets/like-animation.lottie",
        width: Constants.iconButtonSize * widget.shrinkFactor,
        height: Constants.iconButtonSize * widget.shrinkFactor,
        fit: BoxFit.contain,
        decoder: lottieDecoder,
        controller: controller,
        onLoaded: (composition) {
          controller.duration = composition.duration;
        },
        delegates: LottieDelegates(
          values: [
            ValueDelegate.color(
              const ["**"],
              value: color,
            ),
            ValueDelegate.strokeColor(
              const ["**"],
              value: color,
            ),
          ],
        ),
      ),
    );
  }
}
