import 'package:doko_react/features/User/Feed/presentation/user_feed_page.dart';
import 'package:doko_react/features/User/Nearby/presentation/nearby_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/login_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/signup_page.dart';
import 'package:flutter/material.dart';

class AuthenticatedRoutes extends StatefulWidget {
  const AuthenticatedRoutes({super.key});

  @override
  State<AuthenticatedRoutes> createState() => _AuthenticatedRoutesState();
}

class _AuthenticatedRoutesState extends State<AuthenticatedRoutes> {
  int currentPageIndex = 0;

  List<Widget> _getDestinations() {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return <Widget>[
      NavigationDestination(
        selectedIcon: Icon(
          Icons.home,
          color: currTheme.onPrimary,
        ),
        icon: const Icon(Icons.home_outlined),
        label: "Home",
      ),
      NavigationDestination(
        selectedIcon: Icon(
          Icons.broadcast_on_personal,
          color: currTheme.onPrimary,
        ),
        icon: const Icon(Icons.broadcast_on_personal_outlined),
        label: "Nearby",
      ),
      NavigationDestination(
        selectedIcon: Icon(
          Icons.account_circle,
          color: currTheme.onPrimary,
        ),
        icon: const Icon(Icons.account_circle_outlined),
        label: "Profile",
      ),
    ];
  }

  Widget _getBody() {
    return <Widget>[
      const UserFeedPage(),
      const NearbyPage(),
      const ProfilePage()
    ][currentPageIndex];
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: currTheme.primary,
          selectedIndex: currentPageIndex,
          destinations: _getDestinations()),
      body: _getBody(),
    );
  }
}
