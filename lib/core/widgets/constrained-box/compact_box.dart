import 'dart:math';

import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class CompactBox extends StatelessWidget {
  const CompactBox({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width, Constants.compact);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Constants.compact,
          minWidth: width,
        ),
        child: child,
      ),
    );
  }
}
