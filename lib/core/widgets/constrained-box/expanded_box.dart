import 'dart:math';

import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ExpandedBox extends StatelessWidget {
  const ExpandedBox({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width, Constants.expanded);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Constants.expanded,
          minWidth: width,
        ),
        child: child,
      ),
    );
  }
}
