import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

enum StyledTextStyle {
  normal,
  error,
  success,
}

class StyledText extends StatelessWidget {
  const StyledText(
    this.text, {
    super.key,
    this.size = Constants.fontSize,
  }) : style = StyledTextStyle.normal;

  const StyledText.error(
    this.text, {
    super.key,
    this.size = Constants.fontSize,
  }) : style = StyledTextStyle.error;

  const StyledText.success(
    this.text, {
    super.key,
    this.size = Constants.fontSize,
  }) : style = StyledTextStyle.success;

  final String text;
  final double size;
  final StyledTextStyle style;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    var textColor = currTheme.onSurface;
    if (style == StyledTextStyle.error) textColor = currTheme.error;
    if (style == StyledTextStyle.success) textColor = Colors.green;

    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: size,
      ),
      textAlign: TextAlign.center,
    );
  }
}
