import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/data/destinations.dart';
import 'package:flutter/material.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({
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
    bool extended = MediaQuery.sizeOf(context).width >= Constants.large;

    return NavigationRail(
      extended: extended,
      groupAlignment: 0,
      labelType: extended ? null : NavigationRailLabelType.all,
      indicatorColor: (selectedIndex != 2 || profileEmpty)
          ? currTheme.primary
          : Colors.transparent,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations.map((destination) {
        return NavigationRailDestination(
          icon: destination.icon,
          label: Text(destination.label),
          selectedIcon: destination.selectedIcon,
        );
      }).toList(),
    );
  }
}
