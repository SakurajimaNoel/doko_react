import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/archive/core/configs/router/router_constants.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/widgets/heading/heading.dart';
import 'package:doko_react/archive/core/widgets/loader/loader.dart';
import 'package:doko_react/archive/core/widgets/loader/loader_button.dart';
import 'package:doko_react/archive/features/User/Profile/widgets/friends/friend_widget.dart';
import 'package:doko_react/archive/features/User/data/model/friend_model.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PendingOutgoingRequests extends StatefulWidget {
  const PendingOutgoingRequests({super.key});

  @override
  State<PendingOutgoingRequests> createState() =>
      PendingOutgoingRequestsState();
}

class PendingOutgoingRequestsState extends State<PendingOutgoingRequests>
    with AutomaticKeepAliveClientMixin {
  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

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
        .getPendingOutgoingFriendsByUsername(_userProvider.username);

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
    String username = _userProvider.username;
    String cursor = _friendInfo!.info.endCursor!;

    var friendResponse =
        await _userGraphqlService.getPendingOutgoingFriendsByUsername(
      username,
      cursor: cursor,
    );

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
      duration: Constants.snackBarDuration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleCancelAction(int index) {
    _friendInfo?.friends.removeAt(index);
    setState(() {});
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

    void cancelCallback() {
      _handleCancelAction(index);
    }

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
        widgetLocation: FriendWidgetLocation.outgoing,
        cancelReqAction: cancelCallback,
        key: ValueKey(friend.id),
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

    return ListView.separated(
      padding: const EdgeInsets.all(
        Constants.padding,
      ),
      itemCount: friends.length + 1,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index, friends),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: Constants.gap,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
