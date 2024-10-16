import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String text;
  final double? size;

  const Heading(
    this.text, {
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: size ?? Constants.heading1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
