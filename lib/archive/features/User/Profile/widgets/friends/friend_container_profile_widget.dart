import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/features/User/Profile/widgets/friends/friend_widget.dart';
import 'package:doko_react/archive/features/User/data/model/friend_model.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendContainerProfileWidget extends StatefulWidget {
  final ProfileFriendInfo friendInfo;
  final String username;

  const FriendContainerProfileWidget({
    super.key,
    required this.friendInfo,
    required this.username,
  });

  @override
  State<FriendContainerProfileWidget> createState() =>
      _FriendContainerProfileWidgetState();
}

class _FriendContainerProfileWidgetState
    extends State<FriendContainerProfileWidget> {
  late final ProfileFriendInfo _friendInfo;

  late final String username;
  late final UserProvider _userProvider;
  late final bool self;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  bool _loading = false;

  late List<FriendUserModel> _friends;

  @override
  void initState() {
    super.initState();

    _friendInfo = widget.friendInfo;

    username = widget.username;

    _userProvider = context.read<UserProvider>();

    self = _userProvider.username == username;

    _friends = _friendInfo.friends;
  }

  Future<void> _fetchMoreFriends() async {
    // only call this function when has next page
    String cursor = _friendInfo.info.endCursor!;

    var friendResponse = await _userGraphqlService.getFriendsByUsername(
      username,
      cursor: cursor,
      currentUsername: _userProvider.username,
    );

    _loading = false;

    if (friendResponse.status == ResponseStatus.error) {
      String message = "Error fetching more user friends";
      _handleError(message);
      return;
    }

    if (friendResponse.friendInfo == null) {
      _friendInfo.info.updateInfo(null, false);
      return;
    }

    _friendInfo.addFriends(friendResponse.friendInfo!.friends);
    setState(() {
      _friends = _friendInfo.friends;
    });
    _friendInfo.info.updateInfo(friendResponse.friendInfo!.info.endCursor,
        friendResponse.friendInfo!.info.hasNextPage);
  }

  void _handleError(String message) {
    var snackBar = SnackBar(
      content: Text(message),
      duration: Constants.snackBarDuration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleUnfriendAction(int index) {
    if (!self) return;

    _friends.removeAt(index);
    setState(() {});
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index >= _friends.length) {
      // fetch more friends if available
      if (!_friendInfo.info.hasNextPage) {
        // no more friends available
        return Center(
          child: Text(
            "@$username has no more friends.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      if (!_loading) {
        _loading = true;
        _fetchMoreFriends();
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    var friend = _friends[index];
    void removeCallback() {
      _handleUnfriendAction(index);
    }

    return FriendWidget(
      friend: friend,
      widgetLocation:
          self ? FriendWidgetLocation.myFriends : FriendWidgetLocation.friends,
      removeFriendAction: removeCallback,
      key: ValueKey(friend.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_friends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: Constants.padding,
        ),
        child: Center(
          child: Text(
            "@$username has no friends.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(
        Constants.padding,
      ),
      child: ListView.separated(
        itemCount: _friends.length + 1,
        itemBuilder: (BuildContext context, int index) =>
            _buildItem(context, index),
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: Constants.gap,
          );
        },
      ),
    );
  }
}
