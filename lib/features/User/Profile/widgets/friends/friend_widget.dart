import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/Profile/widgets/user/user_widget.dart';
import 'package:doko_react/features/User/data/graphql_queries/friend_relation.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FriendWidgetLocation {
  incoming, // my incoming friends
  outgoing, // my outgoing friends
  myFriends, // my friends
  friends, // user friends
  search, // general user search
}

class FriendWidget extends StatelessWidget {
  final FriendUserModel friend;
  final FriendWidgetLocation widgetLocation;
  final VoidCallback? removeFriendAction;
  final VoidCallback? cancelReqAction;

  const FriendWidget({
    super.key,
    required this.friend,
    this.removeFriendAction,
    required this.widgetLocation,
    this.cancelReqAction,
  })  : assert(
            widgetLocation != FriendWidgetLocation.myFriends ||
                removeFriendAction != null,
            "required removeFriendAction to handle user unfriend action"),
        assert(
            (widgetLocation != FriendWidgetLocation.incoming &&
                    widgetLocation != FriendWidgetLocation.outgoing) ||
                cancelReqAction != null,
            "required cancelReqAction to handle user cancel their request.");

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserWidget(user: friend),
        _UserAction(
          friend: friend,
          removeFriendAction: removeFriendAction,
          cancelReqAction: cancelReqAction,
        ),
      ],
    );
  }
}

class _UserAction extends StatefulWidget {
  final FriendUserModel friend;
  final VoidCallback? removeFriendAction;
  final VoidCallback? cancelReqAction;

  const _UserAction({
    required this.friend,
    this.removeFriendAction,
    this.cancelReqAction,
  });

  @override
  State<_UserAction> createState() => _UserActionState();
}

class _UserActionState extends State<_UserAction>
    with AutomaticKeepAliveClientMixin {
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
      _friend.friendRelationDetail,
      currentUsername: _userProvider.username,
    );
    _self = _friend.username == _userProvider.username;
  }

  Future<void> _handleAdd() async {
    setState(() {
      _status = FriendRelationStatus.outgoingReq;
      _updating = true;
    });

    String requestedByUsername = _userProvider.username;
    String requestedToUsername = _friend.username;

    var addResponse = await _userGraphqlService.userSendFriendRequest(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );
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
      requestedByUsername: requestedByUsername,
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
        errorMessage = Constants.errorMessage;
    }

    setState(() {
      _status = FriendRelationStatus.unrelated;
      _updating = true;
    });

    String requestedByUsername =
        _friend.friendRelationDetail!.requestedByUsername;
    String requestedToUsername = requestedByUsername == _userProvider.username
        ? _friend.username
        : _userProvider.username;

    var cancelResponse = await _userGraphqlService.userRemoveFriendRelation(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );
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
    // success action
    if (widget.removeFriendAction != null) widget.removeFriendAction!();
    if (widget.cancelReqAction != null) widget.cancelReqAction!();
  }

  Future<void> _handleAccept() async {
    setState(() {
      _status = FriendRelationStatus.friends;
      _updating = true;
    });

    String requestedByUsername =
        _friend.friendRelationDetail!.requestedByUsername;
    String requestedToUsername = requestedByUsername == _userProvider.username
        ? _friend.username
        : _userProvider.username;

    var acceptResponse = await _userGraphqlService.userAcceptFriendRequest(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );

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
    // success action
    if (widget.cancelReqAction != null) {
      widget.cancelReqAction!(); // reusing same callback as cancelReqAction
    }
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
    super.build(context);

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

    // friends
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

  @override
  bool get wantKeepAlive => true;
}
