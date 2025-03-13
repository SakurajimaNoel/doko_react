import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  /// normal used for page loads
  const LoadingWidget({
    super.key,
    this.color,
  })  : diameter = Constants.height * 3.5,
        size = 3.5;

  /// used with cached network image and search and full size buttons
  const LoadingWidget.small({
    super.key,
    this.color,
  })  : diameter = Constants.height * 2.5,
        size = 2.5;

  /// used with user avatar network image and inside buttons
  const LoadingWidget.nested({
    super.key,
    this.color,
  })  : diameter = Constants.height * 1.5,
        size = 1.5;

  final Color? color;
  final double diameter;
  final double size;

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: diameter,
      width: diameter,
      child: OverflowBox(
        minHeight: Constants.iconButtonSize * size,
        maxHeight: Constants.iconButtonSize * size,
        maxWidth: Constants.iconButtonSize * size,
        minWidth: Constants.iconButtonSize * size,
        child: Lottie.asset(
          "assets/loading-animation.lottie",
          decoder: lottieDecoder,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                const ["**"],
                value: currTheme.primary,
              ),
              ValueDelegate.strokeColor(
                const ["**"],
                value: currTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
