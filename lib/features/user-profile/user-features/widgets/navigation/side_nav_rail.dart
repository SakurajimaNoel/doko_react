import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/create/create_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/data/destinations.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/inbox/inbox_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/pending-requests/pending_requests_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/search/search_widget.dart';
import 'package:flutter/material.dart';

class SideNavRail extends StatelessWidget {
  const SideNavRail({
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

  List<Destinations> createNewDestinations(BuildContext context) {
    List<Destinations> moreDestinations = [
      Destinations(
          icon: const CreateWidget.icon(),
          label: "Create",
          action: () {
            CreateWidget.createOptions(context);
          }),
      Destinations(
          icon: const SearchWidget(
            inNavRail: true,
          ),
          label: "Search",
          action: () {
            SearchWidget.redirect(context);
          }),
      Destinations(
          icon: const PendingRequestsWidget(
            inNavRail: true,
          ),
          label: "Request",
          action: () {
            PendingRequestsWidget.redirect(context);
          }),
      Destinations(
          icon: const InboxWidget(
            inNavRail: true,
          ),
          label: "Messages",
          action: () {
            InboxWidget.redirect(context);
          }),
    ];
    destinations.insertAll(2, moreDestinations);
    return destinations;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = createNewDestinations(context);

    bool extended = MediaQuery.sizeOf(context).width > Constants.expanded;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: NavigationRail(
                extended: extended,
                minExtendedWidth: Constants.width * 12,
                groupAlignment: 0,
                labelType: extended ? null : NavigationRailLabelType.all,
                indicatorShape: const CircleBorder(),
                indicatorColor: indicatorColor,
                selectedIndex: selectedIndex == 2
                    ? destinations.length - 1
                    : selectedIndex,
                onDestinationSelected: (index) {
                  if (index > 1 && index < destinations.length - 1) {
                    if (destinations[index].action != null) {
                      destinations[index].action!();
                    }
                    return;
                  }
                  if (index == destinations.length - 1) index = 2;
                  onDestinationSelected(index);
                },
                destinations: destinations.map((destination) {
                  return NavigationRailDestination(
                    icon: destination.icon,
                    label: Text(destination.label),
                    selectedIcon: destination.selectedIcon,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
