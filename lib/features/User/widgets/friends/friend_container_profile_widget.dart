import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/helpers/enum.dart';
import '../../../../core/widgets/loader_button.dart';
import '../../data/services/user_graphql_service.dart';

class FriendContainerProfileWidget extends StatefulWidget {
  final ProfileFriendInfo friendInfo;
  final UserModel user;

  const FriendContainerProfileWidget({
    super.key,
    required this.friendInfo,
    required this.user,
  });

  @override
  State<FriendContainerProfileWidget> createState() =>
      _FriendContainerProfileWidgetState();
}

class _FriendContainerProfileWidgetState
    extends State<FriendContainerProfileWidget>
    with AutomaticKeepAliveClientMixin {
  late final ProfileFriendInfo _friendInfo;
  late final UserModel _user;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  bool _loading = false;

  // String _errorMessage = "";
  late final List<UserModel> _friends;

  @override
  void initState() {
    super.initState();

    _friendInfo = widget.friendInfo;
    _user = widget.user;

    _friends = _friendInfo.friends;
  }

  Future<void> _fetchMoreFriends() async {
    // only call this function when has next page
    String id = _user.id;
    String cursor = _friendInfo.info.endCursor!;

    var friendResponse =
        await _userGraphqlService.getFriendsByUserId(id, cursor);

    _loading = false;

    if (friendResponse.status == ResponseStatus.error) {
      // setState(() {
      //   _errorMessage = "Error fetching user friends.";
      // });
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

  Widget _buildItem(BuildContext context, int index) {
    if (index >= _friends.length) {
      // fetch more friends if available
      if (!_friendInfo.info.hasNextPage) {
        // no more posts available
        return Padding(
          padding: const EdgeInsets.only(
            bottom: Constants.padding,
          ),
          child: Center(
            child: Text(
              "${_user.name} has no more friends.",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      if (!_loading) {
        _loading = true;
        _fetchMoreFriends();
      }
      return const Center(
        child: LoaderButton(),
      );
    }

    String name = _friends[index].name;
    return Text(name);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_friends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: Constants.padding,
        ),
        child: Center(
          child: Text(
            "${_user.name} has no friends.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _friends.length + 1,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
