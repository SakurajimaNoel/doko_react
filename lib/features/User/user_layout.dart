import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UserLayout(this.navigationShell, {super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  late final UserProvider _userProvider;
  late int _index;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _index = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;
    final UserProvider userProvider = context.watch<UserProvider>();

    List<Widget> getDestinations() {
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
          selectedIcon: userProvider.profilePicture.isEmpty
              ? Icon(
                  Icons.account_circle,
                  color: currTheme.onPrimary,
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: currTheme.primary,
                  child: CircleAvatar(
                    radius: 17,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        cacheKey: userProvider.profilePicture,
                        imageUrl: userProvider.signedProfilePicture,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: 34,
                        height: 34,
                        memCacheHeight: Constants.thumbnailCacheHeight,
                      ),
                    ),
                  ),
                ),
          icon: userProvider.profilePicture.isEmpty
              ? const Icon(Icons.account_circle_outlined)
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: currTheme.primary,
                  child: CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        cacheKey: userProvider.profilePicture,
                        imageUrl: userProvider.signedProfilePicture,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        memCacheHeight: Constants.thumbnailCacheHeight,
                      ),
                    ),
                  ),
                ),
          label: DisplayText.trimText(userProvider.name, len: 10),
        ),
      ];
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        indicatorColor: _index != 2
            ? currTheme.primary
            : userProvider.profilePicture.isEmpty
                ? currTheme.primary
                : Colors.transparent,
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: getDestinations(),
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  void _onDestinationSelected(index) {
    int prevInd = widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (prevInd == 2 && _userProvider.profilePicture.isNotEmpty) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          setState(() {
            _index = index;
          });
        },
      );
    } else {
      setState(() {
        _index = index;
      });
    }
  }
}
