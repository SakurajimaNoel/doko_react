import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/debounce.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/widgets/loader/loader.dart';
import 'package:doko_react/archive/core/widgets/loader/loader_button.dart';
import 'package:doko_react/archive/features/User/Profile/widgets/friends/friend_container_profile_widget.dart';
import 'package:doko_react/archive/features/User/Profile/widgets/friends/friend_widget.dart';
import 'package:doko_react/archive/features/User/data/model/friend_model.dart';
import 'package:doko_react/archive/features/User/data/model/model.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  final String username;

  const FriendsPage({
    super.key,
    required this.username,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final String username;
  late final bool self;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  late final UserProvider _userProvider;

  bool _loading = true;
  ProfileFriendInfo _friendInfo = ProfileFriendInfo(
    friends: [],
    info: NodeInfo(
      endCursor: null,
      hasNextPage: false,
    ),
  );

  // user search
  List<FriendUserModel>? searchResult;
  bool searching = false;

  final Debounce searchDebounce = Debounce(
    const Duration(
      milliseconds: 500,
    ),
  );

  @override
  void initState() {
    super.initState();

    username = widget.username;

    _userProvider = context.read<UserProvider>();
    _getUserFriends();
    self = _userProvider.username == username;
  }

  Future<void> _getUserFriends() async {
    var friendResponse = await _userGraphqlService.getFriendsByUsername(
      username,
      currentUsername: _userProvider.username,
    );

    setState(() {
      _loading = false;
    });

    if (friendResponse.status == ResponseStatus.error) {
      String message = "can't fetch @$username friends.";
      _handleError(message);
      return;
    }

    setState(() {
      _friendInfo = friendResponse.friendInfo!;
    });
  }

  void _handleError(String message) {
    var snackBar = SnackBar(
      content: Text(message),
      duration: Constants.snackBarDuration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> searchUser(String query) async {
    setState(() {
      searching = true;
    });
    String currentUsername = _userProvider.username;

    SearchResponse searchResponse =
        await _userGraphqlService.searchUserFriendsByUsernameOrName(
      username,
      currentUsername: currentUsername,
      query: query,
    );

    if (searching == false) return;

    setState(() {
      searching = false;
      searchResult = searchResponse.users;
    });

    if (searchResponse.status == ResponseStatus.error) {
      _handleError(Constants.errorMessage);
      return;
    }
  }

  void _handleUnfriendAction(int index) {
    if (!self || searchResult == null) return;

    searchResult!.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    var currScheme = Theme.of(context).colorScheme;

    if (_loading) {
      widget = const Loader();
    } else {
      widget = Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_friendInfo.info.hasNextPage) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.padding,
              ),
              child: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  TextField(
                    onChanged: (String value) {
                      if (value.isEmpty) {
                        setState(() {
                          searchResult = null;
                          searching = false;
                        });
                        searchDebounce.dispose();
                        return;
                      }

                      searchDebounce(() => searchUser(value));
                    },
                    decoration: const InputDecoration(
                      labelText: "Search friends",
                      hintText: "Search friends by username or name.",
                    ),
                  ),
                  if (searching)
                    const LoaderButton()
                  else if (searchResult != null)
                    Icon(
                      Icons.check,
                      color: currScheme.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
          ],
          Flexible(
            child: searchResult == null
                ? FriendContainerProfileWidget(
                    friendInfo: _friendInfo,
                    username: username,
                  )
                : searchResult!.isEmpty
                    ? const Center(
                        child: Text("No user found with given query"),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.padding,
                        ),
                        itemCount: searchResult!.length,
                        itemBuilder: (BuildContext context, int index) {
                          void removeCallback() {
                            _handleUnfriendAction(index);
                          }

                          return FriendWidget(
                            removeFriendAction: removeCallback,
                            friend: searchResult![index],
                            widgetLocation: self
                                ? FriendWidgetLocation.myFriends
                                : FriendWidgetLocation.friends,
                            key: ObjectKey(
                              searchResult![index],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: Constants.gap,
                          );
                        },
                      ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$username friends"),
      ),
      body: widget,
    );
  }
}
