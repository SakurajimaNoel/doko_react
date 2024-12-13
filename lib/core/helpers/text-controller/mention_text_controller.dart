import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:flutter/material.dart';

class CommentContentInput {
  final List<String> content;
  final Set<String> mentions;

  const CommentContentInput({
    required this.content,
    required this.mentions,
  });
}

class MentionTextController extends TextEditingController {
  final List<String> _mentions = [];

  @override
  void clear() {
    _mentions.clear();
    super.clear();
  }

  TextSpan _buildText(
    String str, {
    TextStyle? style,
  }) {
    return TextSpan(
      text: str,
      style: style,
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
    final TextStyle mentionStyle = TextStyle(
      color: mentionColor,
      fontWeight: FontWeight.w500,
    );

    final RegExp usernameRegex = RegExp(
      r"[@]" + Constants.usernameRegex + r"[" + Constants.zeroWidthSpace + r"]",
      multiLine: true,
      unicode: true,
    );

    final usernames = usernameRegex.allMatches(text);

    int startIndex = 0;
    final children = <TextSpan>[];

    for (final username in usernames) {
      int start = username.start;
      int end = username.end;

      final String normalText = text.substring(startIndex, start);
      final String mentionedText = text.substring(start, end);

      startIndex = end;

      children.add(_buildText(normalText));
      children.add(_buildText(
        mentionedText,
        style: mentionStyle,
      ));
    }
    final String remainingText = text.substring(startIndex);
    children.add(_buildText(remainingText));

    return TextSpan(
      style: style,
      children: children,
    );
  }

  void addMention(String username) {
    final String inputUsername = "@$username${Constants.zeroWidthSpace} ";

    final String currentText = text;
    final TextSelection currentSelection = selection;

    final int offset = currentSelection.start;
    final int len = currentText.length;

    String beforeSelection = currentText.substring(0, offset);
    String afterSelection = offset == len ? "" : currentText.substring(offset);

    final int triggerIndex = beforeSelection.lastIndexOf("@");
    if (triggerIndex == -1) {
      // invalid state
      return;
    }
    _mentions.add(inputUsername.trim());

    final int mentionEndIndex =
        afterSelection.indexOf(Constants.zeroWidthSpace);
    final int mentionTriggerIndex = afterSelection.indexOf("@");
    final bool isExisting = mentionEndIndex != -1 &&
        (mentionTriggerIndex == -1 || mentionEndIndex < mentionTriggerIndex);

    if (isExisting) {
      // remove the part from afterSelection string
      afterSelection = afterSelection.replaceRange(0, mentionEndIndex + 1, "");
    } else {
      /// for non existing mention remove till next space
      /// in existing only removing till the mention because
      /// input can be @rohan[zws]string (without space) than
      /// it will also replace string portion (which is not intended for user
      final int textEndIndex = afterSelection.indexOf(" ");
      if (textEndIndex != -1) {
        afterSelection = afterSelection.replaceRange(0, textEndIndex + 1, "");
      } else {
        afterSelection = afterSelection.replaceRange(0, null, "");
      }
    }

    // to handle space between mention and rest
    final String mentionTriggerPrefix =
        (triggerIndex > 0 && beforeSelection[triggerIndex - 1] != " ")
            ? " "
            : "";
    // replace the string in before selection to mentioned text
    beforeSelection = beforeSelection.replaceRange(
        triggerIndex, null, "$mentionTriggerPrefix$inputUsername");

    text = "${beforeSelection.trim()} ${afterSelection.trim()}";
    selection = TextSelection.collapsed(offset: beforeSelection.length);
  }

  void createCommentInput(List<String> comment) {
    final RegExp usernameRegex = RegExp(
      r"^[@]" +
          Constants.usernameRegex +
          r"[" +
          Constants.zeroWidthSpace +
          r"]$",
      multiLine: true,
      unicode: true,
    );

    String commentString = "";
    for (var str in comment) {
      commentString += str;
      if (usernameRegex.hasMatch(str)) _mentions.add(str);
    }

    text = commentString;
  }

  CommentContentInput getCommentInput() {
    List<String> comment = [];
    Set<String> uniqueMentions = {};
    List<String> tempMentions = List<String>.from(_mentions);
    final RegExp usernameRegex = RegExp(
      r"[@]" + Constants.usernameRegex + r"[" + Constants.zeroWidthSpace + r"]",
      multiLine: true,
      unicode: true,
    );

    final usernames = usernameRegex.allMatches(text);
    int startIndex = 0;

    for (final username in usernames) {
      int start = username.start;
      int end = username.end;

      final String normalString = text.substring(startIndex, start);
      String mentionedString = text.substring(start, end);

      startIndex = end;

      if (tempMentions.contains(mentionedString)) {
        // is username is present in mentions add 2 elements
        tempMentions.remove(mentionedString);
        uniqueMentions.add(getUsernameFromCommentInput(mentionedString));
        comment.addAll([normalString, mentionedString]);
        continue;
      }

      if (mentionedString.isNotEmpty) {
        // remove zero width character at the end of the user name to make it normal string
        mentionedString =
            mentionedString.substring(0, mentionedString.length - 1);
      }
      comment.add(normalString + mentionedString);
    }
    comment.add(text.substring(startIndex));

    // remove all the empty fields
    comment.removeWhere((String str) => str.isEmpty);

    return CommentContentInput(
      content: comment,
      mentions: uniqueMentions,
    );
  }
}
