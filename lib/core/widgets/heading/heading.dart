import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    super.key,
    this.size,
  }) : centred = true;

  const Heading.left(
    this.text, {
    super.key,
    this.size,
  }) : centred = false;

  final String text;
  final double? size;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: centred ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: size ?? Constants.heading1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
