import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserLayout extends StatefulWidget {
  const UserLayout(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  late int activeIndex;

  @override
  void initState() {
    super.initState();

    activeIndex = widget.navigationShell.currentIndex;
  }

  List<Widget> getDestinations(UserEntity user) {
    final currTheme = Theme.of(context).colorScheme;

    return [
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
        selectedIcon: user.profilePicture.bucketPath.isEmpty
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
                      cacheKey: user.profilePicture.bucketPath,
                      imageUrl: user.profilePicture.accessURI,
                      placeholder: (context, url) => const Center(
                        child: SmallLoadingIndicator.small(),
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
        icon: user.profilePicture.bucketPath.isEmpty
            ? const Icon(Icons.account_circle_outlined)
            : CircleAvatar(
                radius: 20,
                backgroundColor: currTheme.primary,
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      cacheKey: user.profilePicture.bucketPath,
                      imageUrl: user.profilePicture.accessURI,
                      placeholder: (context, url) => const Center(
                        child: SmallLoadingIndicator.small(),
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
        label: trimText(user.name, len: 10),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionUpdateProfile;
      },
      builder: (context, state) {
        final username =
            (context.read<UserBloc>().state as UserCompleteState).username;
        String key = generateUserNodeKey(username);

        final UserGraph graph = UserGraph();
        UserEntity user = graph.getValueByKey(key)! as UserEntity;
        bool profileEmpty = user.profilePicture.bucketPath.isEmpty;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) {
            /// this handles going to user feed page
            /// when in one of the other pages of
            /// stateful shell route
            if (didPop) return;

            if (activeIndex == 0) {
              // todo: disconnect xmpp client here
              SystemNavigator.pop();
              return;
            }
            onDestinationSelected(0, profileEmpty);
          },
          child: Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: NavigationBar(
              indicatorColor: (activeIndex != 2 || profileEmpty)
                  ? currTheme.primary
                  : Colors.transparent,
              selectedIndex: widget.navigationShell.currentIndex,
              destinations: getDestinations(user),
              onDestinationSelected: (index) =>
                  onDestinationSelected(index, profileEmpty),
            ),
          ),
        );
      },
    );
  }

  void onDestinationSelected(int index, bool profileEmpty) {
    int prevIndex = widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (prevIndex == 2 && !profileEmpty) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          setState(() {
            activeIndex = index;
          });
        },
      );
    } else {
      setState(() {
        activeIndex = index;
      });
    }
  }
}
