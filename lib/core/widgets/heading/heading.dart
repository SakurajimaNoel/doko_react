import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    super.key,
    this.size,
    this.color,
  }) : centred = true;

  const Heading.left(
    this.text, {
    super.key,
    this.size,
    this.color,
  }) : centred = false;

  final String text;
  final double? size;
  final bool centred;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: centred ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: size ?? Constants.heading1,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
