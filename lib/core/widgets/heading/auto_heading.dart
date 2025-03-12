import 'package:auto_size_text/auto_size_text.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AutoHeading extends StatelessWidget {
  const AutoHeading(
    this.text, {
    super.key,
    this.size,
    this.color,
    this.fontWeight,
    this.minFontSize = Constants.smallFontSize,
    this.maxLines = 1,
  }) : centred = true;

  const AutoHeading.left(
    this.text, {
    super.key,
    this.size,
    this.color,
    this.fontWeight,
    this.minFontSize = Constants.smallFontSize,
    this.maxLines = 1,
  }) : centred = false;

  final String text;
  final double? size;
  final bool centred;
  final Color? color;
  final FontWeight? fontWeight;

  final int maxLines;
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      textAlign: centred ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: size ?? Constants.heading1,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
        overflow: TextOverflow.ellipsis,
      ),
      maxFontSize: size ?? Constants.heading1,
      minFontSize: minFontSize,
      maxLines: 1,
    );
  }
}
