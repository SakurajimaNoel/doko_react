import 'package:flutter/cupertino.dart';

class SettingsHeading extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? fontWeight;

  const SettingsHeading(this.text, {super.key, this.size, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.w600,
        fontSize: size ?? 18,
      ),
    );
  }
}
