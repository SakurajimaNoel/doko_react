import 'package:doko_react/features/user-profile/user-features/widgets/navigation/data/destinations.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.profileEmpty,
  });

  final int selectedIndex;
  final ValueSetter<int> onDestinationSelected;
  final List<Destinations> destinations;
  final bool profileEmpty;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    return NavigationBar(
      indicatorColor: (selectedIndex != 2 || profileEmpty)
          ? currTheme.primary
          : Colors.transparent,
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
