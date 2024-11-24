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

  Widget generateTextWidget() {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ?? Constants.heading1,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (centred) {
      return Center(
        child: generateTextWidget(),
      );
    }

    return generateTextWidget();
  }
}
