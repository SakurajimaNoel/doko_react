import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class SmallLoadingIndicator extends StatelessWidget {
  const SmallLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Constants.height * 1.5,
      width: Constants.height * 1.5,
      child: CircularProgressIndicator(
        strokeWidth: 3,
      ),
    );
  }
}
