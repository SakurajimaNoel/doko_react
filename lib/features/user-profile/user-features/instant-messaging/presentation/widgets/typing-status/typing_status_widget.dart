import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingStatusWidget extends StatelessWidget {
  const TypingStatusWidget.sticker({
    super.key,
    required this.username,
  }) : text = false;

  /// this is used in inbox page
  const TypingStatusWidget.text({
    super.key,
    required this.username,
  }) : text = true;

  final String username;

  // same behaviour as typing status widget wrapper
  final bool text;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (text) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool shrink = constraints.maxWidth < 215;
          double animationFactor = shrink ? 2 : 3;
          double animationBoxFactor = shrink ? 0.5 : 1;
          double textFactor = shrink ? 1 : 1.125;

          bool hideUsername = constraints.maxWidth < 175;

          String typingText;
          if (hideUsername) {
            typingText = "Typing";
          } else {
            typingText = "@${trimText(
              username,
              len: shrink ? 12 : 50,
            )} is typing";
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Constants.gap * 0.25,
            children: [
              Text(
                typingText,
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
          );
        },
      );
    }

    // status sticker
    return SizedBox(
      height: Constants.height * 4,
      width: Constants.height * 4,
      child: Lottie.asset(
        "assets/typing-animation-sticker.lottie",
        decoder: lottieDecoder,
      ),
    );
  }
}
