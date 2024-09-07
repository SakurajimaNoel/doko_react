import 'package:flutter/material.dart';

import '../helpers/constants.dart';

class LoaderButton extends StatelessWidget {
  const LoaderButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Constants.buttonHeight / 2,
      width: Constants.buttonLoaderWidth,
      child: CircularProgressIndicator(),
    );
  }
}
