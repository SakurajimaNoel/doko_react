import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    super.key,
    this.size,
  });

  final String text;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: size ?? Constants.heading1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
