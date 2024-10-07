import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';

class LoaderButton extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const LoaderButton({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height ?? Constants.buttonHeight / 2,
      width: width ?? Constants.buttonLoaderWidth,
      child: CircularProgressIndicator(
        color: color ?? currTheme.primary,
      ),
    );
  }
}
