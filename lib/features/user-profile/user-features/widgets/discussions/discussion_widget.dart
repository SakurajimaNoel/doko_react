import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DiscussionWidget extends StatefulWidget {
  const DiscussionWidget({super.key});

  @override
  State<DiscussionWidget> createState() => _DiscussionWidgetState();
}

class _DiscussionWidgetState extends State<DiscussionWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Constants.height * 10,
      child: Placeholder(),
    );
  }
}
