import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/data/graphql_queries/friend_relation.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendWidget extends StatelessWidget {
  final FriendUserModel friend;

  const FriendWidget({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: Constants.gap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              friend.profilePicture.isEmpty
                  ? const CircleAvatar(
                      child: Icon(Icons.person),
                    )
                  : CircleAvatar(
                      child: ClipOval(
                        child: CachedNetworkImage(
                          cacheKey: friend.profilePicture,
                          imageUrl: friend.signedProfilePicture,
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
              const SizedBox(
                width: Constants.gap,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name),
                  Text(
                    "@${friend.username}",
                    style: const TextStyle(
                      fontSize: Constants.smallFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _UserAction(
            friend: friend,
          ),
        ],
      ),
    );
  }
}

class _UserAction extends StatefulWidget {
  final FriendUserModel friend;

  const _UserAction({
    required this.friend,
  });

  @override
  State<_UserAction> createState() => _UserActionState();
}

class _UserActionState extends State<_UserAction> {
  late FriendRelationStatus _status;
  late FriendUserModel _friend;

  late final bool _self;
  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();

    _friend = widget.friend;
    _status = FriendRelation.getFriendRelationStatus(
        _friend.friendRelationDetail, _userProvider.id);
    _self = _friend.id == _userProvider.id;
  }

  Future<void> _handleAdd() async {
    setState(() {
      _status = FriendRelationStatus.outgoingReq;
      _updating = true;
    });

    String requestedBy = _userProvider.id;
    String requestedTo = _friend.id;

    var addResponse = await _userGraphqlService.userSendFriendRequest(
        requestedBy, requestedTo);
    setState(() {
      _updating = false;
    });

    if (addResponse == ResponseStatus.error) {
      setState(() {
        _status = FriendRelationStatus.unrelated;
      });
      String message = "can't send friend request to ${_friend.name}";
      _handleError(message);
      return;
    }

    // success
    _friend.friendRelationDetail = FriendConnectionDetail(
      requestedBy: requestedBy,
      status: FriendStatus.pending,
    );
  }

  Future<void> _handleCancel() async {
    var currentStatus = _status;
    var errorMessage =
        "can't cancel your request to ${_friend.name}."; // outgoing req cancel

    switch (currentStatus) {
      case FriendRelationStatus.friends:
        errorMessage = "can't remove ${_friend.name} from your friends.";
      case FriendRelationStatus.incomingReq:
        errorMessage = "can't remove ${_friend.name}'s friend request.";
      default:
        errorMessage = "Oops! Something went wrong.";
    }

    setState(() {
      _status = FriendRelationStatus.unrelated;
      _updating = true;
    });

    String requestedBy = _friend.friendRelationDetail!.requestedBy;
    String requestedTo =
        requestedBy == _userProvider.id ? _friend.id : _userProvider.id;

    var cancelResponse = await _userGraphqlService.userRemoveFriendRelation(
        requestedBy, requestedTo);
    setState(() {
      _updating = false;
    });

    if (cancelResponse == ResponseStatus.error) {
      setState(() {
        _status = currentStatus;
      });
      _handleError(errorMessage);
      return;
    }

    // success
    _friend.friendRelationDetail = null;
  }

  Future<void> _handleAccept() async {
    setState(() {
      _status = FriendRelationStatus.friends;
      _updating = true;
    });

    String requestedBy = _friend.friendRelationDetail!.requestedBy;
    String requestedTo =
        requestedBy == _userProvider.id ? _friend.id : _userProvider.id;

    var acceptResponse = await _userGraphqlService.userAcceptFriendRequest(
        requestedBy, requestedTo);

    setState(() {
      _updating = false;
    });

    if (acceptResponse == ResponseStatus.error) {
      setState(() {
        _status = FriendRelationStatus.incomingReq;
      });
      var message = "can't accept ${_friend.name}'s friend request.";
      _handleError(message);
      return;
    }

    // success
    _friend.friendRelationDetail!.updateStatus(FriendStatus.accepted);
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
    var currScheme = Theme.of(context).colorScheme;

    if (_self) {
      return const SizedBox();
    }

    // unrelated
    if (_status == FriendRelationStatus.unrelated) {
      return IconButton(
        onPressed: _updating
            ? null
            : () {
                _handleAdd();
              },
        icon: Icon(
          Icons.person_add_alt_1,
          color: currScheme.primary,
        ),
        style: IconButton.styleFrom(
          side: BorderSide(
            color: currScheme.primary,
          ),
        ),
      );
    }

    // outgoing req
    if (_status == FriendRelationStatus.outgoingReq) {
      return IconButton(
        onPressed: _updating
            ? null
            : () {
                _handleCancel();
              },
        icon: Icon(
          Icons.close,
          color: currScheme.error,
        ),
        style: IconButton.styleFrom(
          side: BorderSide(
            color: currScheme.error,
          ),
        ),
      );
    }

    // incoming req
    if (_status == FriendRelationStatus.incomingReq) {
      return Row(
        children: [
          IconButton(
            onPressed: _updating
                ? null
                : () {
                    _handleAccept();
                  },
            icon: Icon(
              Icons.check,
              color: currScheme.primary,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: currScheme.primary,
              ),
            ),
          ),
          const SizedBox(
            width: Constants.gap * 0.5,
          ),
          IconButton(
            onPressed: _updating
                ? null
                : () {
                    _handleCancel();
                  },
            icon: Icon(
              Icons.close,
              color: currScheme.error,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: currScheme.error,
              ),
            ),
          )
        ],
      );
    }

    return IconButton(
      onPressed: _updating
          ? null
          : () {
              _handleCancel();
            },
      icon: Icon(
        Icons.close,
        color: currScheme.error,
      ),
      style: IconButton.styleFrom(
        side: BorderSide(
          color: currScheme.error,
        ),
      ),
    );
  }
}
