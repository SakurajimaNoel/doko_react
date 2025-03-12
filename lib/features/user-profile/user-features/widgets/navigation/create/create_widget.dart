import 'dart:math';

import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateWidget extends StatelessWidget {
  const CreateWidget({super.key}) : icon = false;

  const CreateWidget.icon({super.key}) : icon = true;

  final bool icon;

  @override
  Widget build(BuildContext context) {
    if (icon) {
      return IconButton(
        onPressed: () {
          createOptions(context);
        },
        iconSize: 24,
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(6),
        ),
        icon: const Icon(Icons.add_box_outlined),
      );
    }

    return TextButton(
      onPressed: () {
        createOptions(context);
      },
      child: const Text("Create"),
    );
  }

  static void createOptions(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width, Constants.compact);

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          height: Constants.height * 15,
          width: width,
          padding: const EdgeInsets.all(Constants.padding),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: Constants.gap,
              runSpacing: Constants.gap,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPost);
                  },
                  label: const Text("Post"),
                  icon: const Icon(Icons.calendar_view_day_rounded),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createDiscussion);
                  },
                  label: const Text("Discussion"),
                  icon: const Icon(Icons.text_snippet),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPoll);
                  },
                  label: const Text("Poll"),
                  icon: const Icon(Icons.poll),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Page"),
                  icon: const Icon(Icons.pages),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
