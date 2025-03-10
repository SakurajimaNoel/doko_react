import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ArchiveItemOptions extends StatelessWidget {
  const ArchiveItemOptions({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    this.avtar,
  }) : assert(
          avtar != null || icon != null,
          "Either icon or avtar is required.",
        );

  final IconData? icon;
  final String label;
  final Color color;
  // avtar has higher priority than icon
  final Widget? avtar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Row(
        spacing: Constants.gap * 1,
        children: [
          avtar != null
              ? avtar!
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding * 0.375,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: Constants.iconButtonSize * 0.5,
                  ),
                ),
          Text(
            label,
            style: TextStyle(
              fontSize: Constants.fontSize * 0.875,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
