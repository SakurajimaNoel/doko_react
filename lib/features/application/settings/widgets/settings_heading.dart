import 'package:flutter/material.dart';

class SettingsHeading extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;

  const SettingsHeading(this.text,
      {super.key, this.size, this.fontWeight, this.color});

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: size ?? 18,
          color: color ?? currTheme.onSurface),
    );
  }
}
