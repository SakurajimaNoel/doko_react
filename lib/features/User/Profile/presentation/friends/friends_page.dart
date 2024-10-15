import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/model/model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/features/User/widgets/friends/friend_container_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  final String userId;
  final String name;

  const FriendsPage({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final String userId;
  late final String name;

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

  @override
  void initState() {
    super.initState();

    name = widget.name;
    userId = widget.userId;

    _userProvider = context.read<UserProvider>();
    _getUserFriends();
  }

  Future<void> _getUserFriends() async {
    var friendResponse = await _userGraphqlService.getFriendsByUserId(
      userId,
      null,
      currentUserId: _userProvider.id,
    );

    setState(() {
      _loading = false;
    });

    if (friendResponse.status == ResponseStatus.error) {
      String message = "can't fetch $name friends.";
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
      duration: const Duration(
        milliseconds: 1500,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;

    if (_loading) {
      widget = const Loader();
    } else {
      widget = FriendContainerProfileWidget(
        friendInfo: _friendInfo,
        userId: userId,
        name: name,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$name friends"),
      ),
      body: widget,
    );
  }
}
