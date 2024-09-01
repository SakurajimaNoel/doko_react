import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<String> list;

  const BulletList(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("\u2022"),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: Text(item),
            ),
          ],
        );
      }).toList(),
    );
  }
}