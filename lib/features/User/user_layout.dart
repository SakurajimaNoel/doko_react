import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
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

  String _profile = "";

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _getProfile();

    _userProvider.addListener(_getProfile);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    _userProvider.removeListener(_getProfile);
    super.dispose();
  }

  Future<void> _getProfile() async {
    String path = _userProvider.profilePicture;
    if (path.isEmpty) {
      setState(() {
        _profile = "";
        return;
      });
    }

    var result = await StorageActions.getDownloadUrl(path);

    if (result.status == ResponseStatus.success) {
      if (mounted) {
        setState(() {
          _profile = result.value;
        });
      }
    }
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
          selectedIcon: _profile.isEmpty
              ? Icon(
                  Icons.account_circle,
                  color: currTheme.onPrimary,
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: currTheme.primary,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundImage: CachedNetworkImageProvider(
                      _profile,
                      cacheKey: userProvider.profilePicture,
                    ),
                  ),
                ),
          icon: _profile.isEmpty
              ? const Icon(Icons.account_circle_outlined)
              : CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    _profile,
                    cacheKey: userProvider.profilePicture,
                  ),
                ),
          label: DisplayText.trimText(userProvider.name, len: 10),
        ),
      ];
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        indicatorColor: widget.navigationShell.currentIndex != 2
            ? currTheme.primary
            : _profile.isEmpty
                ? currTheme.primary
                : Colors.transparent,
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
