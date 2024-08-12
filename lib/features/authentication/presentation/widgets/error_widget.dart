import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errorText;

  const ErrorText(
    this.errorText, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Text(
      errorText,
      style: TextStyle(
        color: currTheme.error,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
