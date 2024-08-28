import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/loader.dart';
import 'package:doko_react/features/User/CompleteProfile/Presentation/complete_profile_page.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';

import 'package:doko_react/features/authentication/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/data/auth.dart';

class UserLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UserLayout(this.navigationShell, {super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  late final UserProvider _userProvider;
  final UserGraphqlService _graphqlService = UserGraphqlService();

  @override
  void initState() {
    super.initState();

    _userProvider = Provider.of<UserProvider>(context, listen: false);
    AuthenticationActions.getAccessToken();
    _getCompleteUser();
  }

  void _getCompleteUser() async {
    var result = await AuthenticationActions.getUserId();
    if (result.status == AuthStatus.error) {
      _userProvider.apiError();
      return;
    }

    String userId = result.message!;
    var userDetails = await _graphqlService.getUser(userId);

    if (userDetails.status == ResponseStatus.error) {
      _userProvider.apiError();
      return;
    }

    var user = userDetails.user;
    if (user == null) {
      _userProvider.incompleteUser();
      return;
    }

    _userProvider.addUser(
      name: user.name,
      username: user.username,
      profilePicture: user.profilePicture,
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    if (userProvider.status == ProfileStatus.error) {
      return const Error();
    }

    if (userProvider.status == ProfileStatus.loading) {
      return const Loader();
    }

    if (userProvider.status == ProfileStatus.incomplete) {
      return const CompleteProfilePage();
    }

    ColorScheme currTheme = Theme.of(context).colorScheme;

    List<Widget> getDestinations() {
      if (userProvider.status == ProfileStatus.complete) {
        StorageActions.getDownloadUrl(userProvider.profilePicture);
      }

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
          label: DisplayText.trimText(_userProvider.name, len: 10),
        ),
      ];
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        indicatorColor: currTheme.primary,
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: getDestinations(),
        onDestinationSelected: _onDestinationSelected,
        // labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
    );
  }

  void _onDestinationSelected(index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class Error extends StatelessWidget {
  const Error({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ErrorText(
                "Oops! Something went wrong. Please try again later."),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                AuthenticationActions.signOutUser();
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
