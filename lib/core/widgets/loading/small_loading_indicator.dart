import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: Constants.height * 1.5,
      width: Constants.height * 1.5,
      child: CircularProgressIndicator(
        color: color ?? currTheme.primary,
        strokeWidth: 3,
      ),
    );
  }
}
