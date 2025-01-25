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
        seconds: 2,
      ),
    )..value = widget.userLike ? 1.0 : 0;
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

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.all(Constants.padding * 0.125),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        if (widget.userLike) {
          controller.reset();
        } else {
          HapticFeedback.vibrate();
          controller.forward();
        }

        widget.onPress();
      },
      child: Lottie.asset(
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
