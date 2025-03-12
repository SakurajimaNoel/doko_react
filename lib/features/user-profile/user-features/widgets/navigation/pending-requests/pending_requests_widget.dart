import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PendingRequestsWidget extends StatelessWidget {
  const PendingRequestsWidget({
    super.key,
    this.inNavRail = false,
  });

  final bool inNavRail;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.pushNamed(RouterConstants.pendingRequests);
      },
      iconSize: inNavRail ? 24 : null,
      style: inNavRail
          ? IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(6),
            )
          : null,
      icon: const Icon(Icons.person),
    );
  }
}
