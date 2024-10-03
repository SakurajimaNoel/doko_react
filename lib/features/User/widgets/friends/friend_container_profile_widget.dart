import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/widgets/friends/friend_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/helpers/enum.dart';
import '../../../../core/widgets/loader/loader_button.dart';
import '../../data/model/friend_modal.dart';
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
  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  bool _loading = false;

  // String _errorMessage = "";
  late List<FriendUserModel> _friends;

  @override
  void initState() {
    super.initState();

    _friendInfo = widget.friendInfo;
    _user = widget.user;

    _userProvider = context.read<UserProvider>();

    _friends = _friendInfo.friends;
  }

  Future<void> _fetchMoreFriends() async {
    // only call this function when has next page
    String id = _user.id;
    String cursor = _friendInfo.info.endCursor!;

    var friendResponse = await _userGraphqlService.getFriendsByUserId(
      id,
      cursor,
      currentUserId: _userProvider.id,
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
      duration: const Duration(
        milliseconds: 1500,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    var friend = _friends[index];
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouterConstants.userProfile,
          pathParameters: {
            "userId": friend.id,
          },
        );
      },
      child: FriendWidget(
        friend: friend,
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      child: ListView.builder(
        itemCount: _friends.length + 1,
        itemBuilder: (BuildContext context, int index) =>
            _buildItem(context, index),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
