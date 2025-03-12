import 'package:flutter/material.dart';

class Destinations {
  const Destinations({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  final Widget? selectedIcon;
  final Widget icon;
  final String label;
}
