import 'package:doko_react/features/user-profile/user-features/widgets/navigation/data/destinations.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.profileEmpty,
    required this.indicatorColor,
  });

  final int selectedIndex;
  final ValueSetter<int> onDestinationSelected;
  final List<Destinations> destinations;
  final bool profileEmpty;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      indicatorColor: indicatorColor,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations.map((destination) {
        return NavigationDestination(
          icon: destination.icon,
          label: destination.label,
          selectedIcon: destination.selectedIcon,
        );
      }).toList(),
    );
  }
}
