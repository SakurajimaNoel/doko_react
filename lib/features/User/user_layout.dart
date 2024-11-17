import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class UserLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UserLayout(this.navigationShell, {super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);
  late final UserProvider userProvider;
  late int _index;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();
    _index = widget.navigationShell.currentIndex;
  }

  Widget queryException(Refetch? refetch) {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
        actions: [
          TextButton(
            onPressed: () {
              auth.signOutUser();
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.error,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ErrorText(
              Constants.errorMessage,
              fontSize: Constants.fontSize,
            ),
            const SizedBox(
              height: Constants.height * 0.5,
            ),
            ElevatedButton(
              onPressed: () {
                if (refetch != null) refetch();
              },
              child: const Text("Try again"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    List<Widget> getDestinations(final UserModel user) {
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
          selectedIcon: user.profilePicture.isEmpty
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
                        cacheKey: user.profilePicture,
                        imageUrl: user.signedProfilePicture,
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
          icon: user.profilePicture.isEmpty
              ? const Icon(Icons.account_circle_outlined)
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: currTheme.primary,
                  child: CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        cacheKey: user.profilePicture,
                        imageUrl: user.signedProfilePicture,
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
          label: DisplayText.trimText(user.name, len: 10),
        ),
      ];
    }

    return Query(
      options: QueryOptions(
        document: gql(UserQueries.getUser()),
        variables: UserQueries.getUserVariables(userProvider.id),
        pollInterval: Constants.userProfilePollInterval,
      ),
      builder: (QueryResult result, {Refetch? refetch, FetchMore? fetchMore}) {
        List res = result.data?["users"] ?? [];

        if (res.isEmpty && result.isLoading) {
          return const Scaffold(
            body: Loader(),
          );
        }

        if ((res.isEmpty && result.hasException) || res.isEmpty) {
          return queryException(refetch);
        }

        final Future<UserModel> futureUser = UserModel.createModel(map: res[0]);

        return FutureBuilder<UserModel>(
          future: futureUser,
          builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
            if (snapshot.hasError) {
              return queryException(refetch);
            }

            if (!snapshot.hasData) {
              return const Scaffold(
                body: Loader(),
              );
            }

            final user = snapshot.data!;

            return Scaffold(
              body: widget.navigationShell,
              bottomNavigationBar: NavigationBar(
                indicatorColor: _index != 2
                    ? currTheme.primary
                    : user.profilePicture.isEmpty
                        ? currTheme.primary
                        : Colors.transparent,
                selectedIndex: widget.navigationShell.currentIndex,
                destinations: getDestinations(user),
                onDestinationSelected: (index) =>
                    _onDestinationSelected(index, user),
              ),
            );
          },
        );
      },
    );
  }

  void _onDestinationSelected(index, final UserModel user) {
    int prevInd = widget.navigationShell.currentIndex;

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    if (prevInd == 2 && user.profilePicture.isNotEmpty) {
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
