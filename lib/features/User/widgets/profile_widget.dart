import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error_text.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/configs/router/router_constants.dart';
import '../../../core/data/auth.dart';
import '../../../core/data/storage.dart';
import '../../../core/helpers/enum.dart';

class ProfileWidget extends StatefulWidget {
  final CompleteUserModel? user;
  final bool self;
  final Future<void> Function() refreshUser;

  const ProfileWidget({
    super.key,
    required this.user,
    this.self = false,
    required this.refreshUser,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final CompleteUserModel? _user;
  late final bool _self;
  late final Future<void> Function() _refreshUser;
  String _profile = "";
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();

    _user = widget.user;
    _self = widget.self;
    _refreshUser = widget.refreshUser;

    _getProfile(_user?.profilePicture);
  }

  void _updateUser(
      String profilePicture, String bio, String name, bool profileUpdated) {
    if (profileUpdated) {
      _getProfile(profilePicture);
    }

    setState(() {
      _user!.profilePicture = profilePicture;
      _user.name = name;
      _user.bio = bio;
    });
    _userProvider.updateUser(name, profilePicture);
  }

  Future<void> _getProfile(String? path) async {
    if (_user == null) return;
    if (path == null || path.isEmpty) {
      setState(() {
        _profile = "";
      });
      return;
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

  List<Widget> _appBarActions() {
    if (!_self) {
      return [];
    }
    var currScheme = Theme.of(context).colorScheme;

    return [
      IconButton(
        onPressed: () {
          context.goNamed(RouterConstants.settings);
        },
        icon: const Icon(Icons.settings),
        tooltip: "Settings",
      ),
      TextButton(
        onPressed: () {
          AuthenticationActions.signOutUser();
        },
        child: Text(
          "Sign out",
          style: TextStyle(
            color: currScheme.error,
          ),
        ),
      )
    ];
  }

  Widget _noUser() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: _appBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ErrorText(
                "Oops! Something went wrong.",
                fontSize: Constants.fontSize,
              ),
              const SizedBox(
                height: Constants.gap * 0.5,
              ),
              ElevatedButton(
                onPressed: _refreshUser,
                child: const Text("Refresh"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userProfileAction() {
    if (_self) {
      return OutlinedButton(
        onPressed: () {
          // go to edit page
          EditUserModel editUser = EditUserModel(
            name: _user!.name,
            bio: _user.bio,
            profilePicture: _user.profilePicture,
            imgURL: _profile,
            id: _user.id,
          );
          Map<String, dynamic> data = {
            "callback": _updateUser,
            "user": editUser,
          };
          context.goNamed(RouterConstants.editProfile, extra: data);
        },
        child: const Text("Edit"),
      );
    }

    return OutlinedButton(
      onPressed: () {},
      child: const Text("Add"),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return _user == null
        ? _noUser()
        : Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      expandedHeight: Constants.expandedAppBarHeight,
                      title: Text(_user.username),
                      actions: _appBarActions(),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            _profile.isNotEmpty
                                ? Image.network(
                                    _profile,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: currTheme.onSecondary,
                                    child: const Icon(
                                      Icons.person,
                                      size: Constants.expandedAppBarHeight,
                                    ),
                                  ),
                            Container(
                              padding: const EdgeInsets.only(
                                bottom: Constants.padding,
                                left: Constants.padding,
                              ),
                              alignment: Alignment.bottomLeft,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    currTheme.surface.withOpacity(0.5),
                                    currTheme.surface.withOpacity(0.25),
                                    currTheme.surface.withOpacity(0.25),
                                    currTheme.surface.withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: Text(
                                _user.name,
                                style: TextStyle(
                                  color: currTheme.onSurface,
                                  fontSize: Constants.heading2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(Constants.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_user.bio),
                            const SizedBox(
                              height: 16,
                            ),
                            _userProfileAction(),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelColor: currTheme.primary,
                          unselectedLabelColor: currTheme.onSurface,
                          indicatorColor: currTheme.primary,
                          tabs: const [
                            Tab(text: "Posts"),
                            Tab(text: "Friends"),
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: const TabBarView(
                  children: [
                    Text("posts"),
                    Text("friends"),
                  ],
                ),
              ),
            ),
          );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
