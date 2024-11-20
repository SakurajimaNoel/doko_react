import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText(
    this.errorText, {
    super.key,
    this.fontSize,
  });

  final String errorText;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Text(
      errorText,
      style: TextStyle(
        color: currTheme.error,
        fontWeight: FontWeight.w500,
        fontSize: fontSize ?? Constants.smallFontSize,
      ),
      textAlign: TextAlign.center,
    );
  }
}
