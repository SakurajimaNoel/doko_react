import 'package:flutter/material.dart';

class TextMentionController extends TextEditingController {
  // TODO : improve this function
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    style ??= const TextStyle();
    final mentionColor = Theme.of(context).colorScheme.primary;

    final children = <TextSpan>[];

    final words = text.split(" ");
    for (int i = 0; i < words.length; i++) {
      bool isFinal = i == words.length - 1;
      String word = words[i] + (isFinal ? "" : " ");

      if (word.startsWith("@") && word.length > 3) {
        int lim = 20;
        if (!word[1].contains(RegExp(r'[a-zA-Z]')) ||
            word.trim().length > lim + 1) {
          children.add(
            TextSpan(
              text: word,
            ),
          );
          continue;
        }

        children.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: mentionColor,
            ),
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: word,
          ),
        );
      }
    }

    return TextSpan(
      style: style,
      children: children,
    );
  }
}
