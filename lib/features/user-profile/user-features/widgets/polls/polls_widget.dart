import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class PollsWidget extends StatefulWidget {
  const PollsWidget({super.key});

  @override
  State<PollsWidget> createState() => _PollsWidgetState();
}

class _PollsWidgetState extends State<PollsWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Constants.height * 10,
      child: Placeholder(),
    );
  }
}
