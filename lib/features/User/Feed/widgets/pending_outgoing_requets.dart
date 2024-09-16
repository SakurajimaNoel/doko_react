import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/configs/router/router_constants.dart';
import '../../../../core/helpers/constants.dart';
import '../../../../core/helpers/enum.dart';
import '../../../../core/provider/user_provider.dart';
import '../../../../core/widgets/heading.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/loader_button.dart';
import '../../data/model/friend_modal.dart';
import '../../data/services/user_graphql_service.dart';
import '../../widgets/friends/friend_widget.dart';

class PendingOutgoingRequests extends StatefulWidget {
  const PendingOutgoingRequests({super.key});

  @override
  State<PendingOutgoingRequests> createState() =>
      PendingOutgoingRequestsState();
}

class PendingOutgoingRequestsState extends State<PendingOutgoingRequests>
    with AutomaticKeepAliveClientMixin {
  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  late final UserProvider _userProvider;

  bool _loading = true;
  ProfileFriendInfo? _friendInfo;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();
    _getIncomingRequest();
  }

  Future<void> _getIncomingRequest() async {
    var friendResponse = await _userGraphqlService
        .getPendingOutgoingFriendsByUserId(_userProvider.id, null);

    setState(() {
      _loading = false;
    });

    if (friendResponse.status == ResponseStatus.error) {
      String message = "can't fetch incoming friend requests.";
      _handleError(message);
      return;
    }

    setState(() {
      _friendInfo = friendResponse.friendInfo;
    });
  }

  Future<void> _fetchMoreOutgoingRequest() async {
    if (_friendInfo == null) return;

    // only call this function if have next page
    String id = _userProvider.id;
    String cursor = _friendInfo!.info.endCursor!;

    var friendResponse =
        await _userGraphqlService.getPendingOutgoingFriendsByUserId(id, cursor);

    _loading = false;

    if (friendResponse.status == ResponseStatus.error) {
      String message = "Error fetching more user outgoing requests";
      _handleError(message);
      return;
    }

    if (friendResponse.friendInfo == null) {
      _friendInfo!.info.updateInfo(null, false);
      return;
    }

    setState(() {
      _friendInfo!.addFriends(friendResponse.friendInfo!.friends);
    });
    _friendInfo!.info.updateInfo(friendResponse.friendInfo!.info.endCursor,
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

  Widget _buildItem(
      BuildContext context, int index, List<FriendUserModel> friends) {
    if (index >= friends.length) {
      // fetch more friends if available
      if (!_friendInfo!.info.hasNextPage) {
        // no more posts available
        return const Padding(
          padding: EdgeInsets.only(
            bottom: Constants.padding,
          ),
          child: Center(
            child: Text(
              "You have no more pending outgoing requests.",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      if (!_loading) {
        _loading = true;
        _fetchMoreOutgoingRequest();
      }
      return const Center(
        child: LoaderButton(),
      );
    }

    var friend = friends[index];
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

    var friends = _friendInfo?.friends;

    if (_loading) {
      return const Loader();
    }

    if (friends == null || friends.isEmpty) {
      return const Heading(
        "No pending outgoing request",
        size: Constants.fontSize,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(
        Constants.padding,
      ),
      child: ListView.builder(
        itemCount: friends.length + 1,
        itemBuilder: (BuildContext context, int index) =>
            _buildItem(context, index, friends),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
