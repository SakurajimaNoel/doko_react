import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
    this.inNavRail = false,
  });

  final bool inNavRail;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        redirect(context);
      },
      iconSize: inNavRail ? 24 : null,
      style: inNavRail
          ? IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(6),
            )
          : null,
      icon: const Icon(Icons.search),
    );
  }

  static void redirect(BuildContext context) {
    context.pushNamed(RouterConstants.userSearch);
  }
}
