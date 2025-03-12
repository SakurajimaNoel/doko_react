import 'dart:math';

import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class LargeBox extends StatelessWidget {
  const LargeBox({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width, Constants.large);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Constants.large,
          minWidth: width,
        ),
        child: child,
      ),
    );
  }
}
