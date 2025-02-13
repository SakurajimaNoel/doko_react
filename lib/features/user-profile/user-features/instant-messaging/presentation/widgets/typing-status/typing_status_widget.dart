import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingStatusWidget extends StatelessWidget {
  const TypingStatusWidget({
    super.key,
    required this.username,
  }) : canHide = false;

  const TypingStatusWidget.canHide({
    super.key,
    required this.username,
  }) : canHide = true;

  final String username;
  final bool canHide;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool shrink = constraints.maxWidth < 215;
        double animationFactor = shrink ? 2 : 3;
        double animationBoxFactor = shrink ? 0.5 : 1;
        double textFactor = shrink ? 1 : 1.125;

        bool shouldHide = constraints.maxWidth < 175;

        return Padding(
          padding: const EdgeInsets.only(
            bottom: Constants.gap * 0.5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Constants.gap * 0.25,
            children: [
              if (!shouldHide || !canHide)
                Text(
                  "@${trimText(
                    username,
                    len: shrink ? 12 : 50,
                  )} is typing",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Constants.smallFontSize * textFactor,
                    color: currTheme.primary,
                  ),
                ),
              if (shouldHide && canHide)
                Text(
                  "Typing",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: Constants.smallFontSize * textFactor,
                    color: currTheme.primary,
                  ),
                ),
              SizedBox(
                height: Constants.height * 1 * animationBoxFactor,
                width: Constants.height * 2 * animationBoxFactor,
                child: OverflowBox(
                  minHeight: Constants.iconButtonSize * animationFactor,
                  maxHeight: Constants.iconButtonSize * animationFactor,
                  maxWidth: Constants.iconButtonSize * animationFactor,
                  minWidth: Constants.iconButtonSize * animationFactor,
                  child: Lottie.asset(
                    "assets/typing-animation.lottie",
                    decoder: lottieDecoder,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(
                          const ["**"],
                          value: currTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
