import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';

class TextMentionController extends TextEditingController {
  bool _isMention(String word) {
    int lim = Constants.usernameLimit;

    return word.startsWith("@") &&
        word.length > 3 &&
        word[1].contains(RegExp(r'[a-zA-Z]')) &&
        word.trim().length <= lim + 1;
  }

  TextSpan _buildTextSpanForWord(String word, Color mentionColor) {
    bool isMention = _isMention(word);
    TextStyle? mentionStyle = isMention
        ? TextStyle(
            color: mentionColor,
          )
        : null;

    return TextSpan(
      text: word,
      style: mentionStyle,
    );
  }

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

      children.add(_buildTextSpanForWord(word, mentionColor));
    }

    return TextSpan(
      style: style,
      children: children,
    );
  }
}
