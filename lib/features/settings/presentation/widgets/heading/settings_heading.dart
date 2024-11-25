import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:flutter/material.dart';

class SettingsHeading extends StatelessWidget {
  const SettingsHeading(
    this.text, {
    super.key,
  }) : size = Constants.fontSize;

  const SettingsHeading.large(
    this.text, {
    super.key,
  }) : size = Constants.largeFontSize;

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Heading.left(
      text,
      size: size,
    );
  }
}
