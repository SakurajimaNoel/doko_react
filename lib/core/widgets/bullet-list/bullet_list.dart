import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/markdown-display-widget/markdown_display_widget.dart';
import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<String> list;

  const BulletList(
    this.list, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map(
        (item) {
          bool isMarkdown = item.startsWith("@md: ");
          if (isMarkdown) {
            item = item.substring(4);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("\u2022"),
              const SizedBox(
                width: Constants.gap * 0.25,
              ),
              Expanded(
                child: isMarkdown
                    ? MarkdownDisplayWidget(
                        data: item,
                      )
                    : Text(item),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
