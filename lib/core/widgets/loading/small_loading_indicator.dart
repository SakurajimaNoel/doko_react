import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key, this.color})
      : diameter = Constants.height * 1.625;

  const SmallLoadingIndicator.small({super.key, this.color})
      : diameter = Constants.height * 1.375;

  final Color? color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: diameter,
      width: diameter,
      child: CircularProgressIndicator(
        color: color ?? currTheme.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
