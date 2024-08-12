import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errorText;
  final Color? color;

  const ErrorText(this.errorText, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Text(
      errorText,
      style: TextStyle(
        color: color ?? currTheme.error,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
}
