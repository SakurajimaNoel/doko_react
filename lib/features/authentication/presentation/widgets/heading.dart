import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String text;
  final double? size;

  const Heading(this.text, {super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: size ?? 48,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
