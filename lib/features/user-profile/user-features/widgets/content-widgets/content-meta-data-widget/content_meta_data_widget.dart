import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/users_tagged_profile_avtar_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ContentMetaDataWidget extends StatelessWidget {
  const ContentMetaDataWidget({
    super.key,
    required this.nodeKey,
  });

  final String nodeKey;

  void showTaggedUsers({
    required BuildContext context,
    required List<UsersTagged> usersTagged,
  }) {
    final currentUser =
        (context.read<UserBloc>().state as UserCompleteState).username;

    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, controller) {
            final width = MediaQuery.sizeOf(context).width;

            return Container(
              padding: const EdgeInsets.all(
                Constants.padding,
              ),
              width: width,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  spacing: Constants.gap,
                  children: [
                    const Heading(
                      "Users Tagged",
                      size: Constants.heading3,
                    ),
                    Wrap(
                      spacing: Constants.gap,
                      runSpacing: Constants.gap * 0.5,
                      children: [
                        for (UsersTagged user in usersTagged)
                          ActionChip(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Constants.radius * 10),
                            ),
                            onPressed: () {
                              context.pop();

                              final String routeName =
                                  GoRouter.of(context).currentRouteName ?? "";
                              final Map<String, String> pathParams =
                                  GoRouter.of(context)
                                      .currentRoutePathParameters;
                              if ((routeName == RouterConstants.userProfile &&
                                      pathParams["username"] == user.username ||
                                  (routeName == RouterConstants.profile &&
                                      user.username == currentUser))) {
                                return;
                              }

                              context.pushNamed(
                                RouterConstants.userProfile,
                                pathParameters: {
                                  "username": user.username,
                                },
                              );
                            },
                            avatar: CircleAvatar(
                              child: user.profilePicture.bucketPath.isEmpty
                                  ? const Icon(Icons.person)
                                  : ClipOval(
                                      child: CachedNetworkImage(
                                        cacheKey:
                                            user.profilePicture.bucketPath,
                                        imageUrl: user.profilePicture.accessURI,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: SmallLoadingIndicator.small(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.cover,
                                        memCacheHeight:
                                            Constants.thumbnailCacheHeight,
                                      ),
                                    ),
                            ),
                            label: Text(
                              "@${user.username}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();
    final node = graph.getValueByKey(nodeKey)! as GraphEntityWithUserAction;
    final usersTagged = node.usersTagged;

    final currTheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool shrink = constraints.maxWidth < Constants.postMetadataWidth;
          double shrinkFactor = shrink ? 0.875 : 1;

          bool superShrink = constraints.maxWidth < 250;
          double baseFontSize = Constants.smallFontSize * 1.125;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              usersTagged.isNotEmpty
                  ? Row(
                      spacing: Constants.gap * 0.5,
                      children: [
                        UsersTaggedAvtarWidget(
                          usersTagged: usersTagged,
                          nodeCreatedBy: node.createdBy,
                          onTap: () {
                            showTaggedUsers(
                              context: context,
                              usersTagged: usersTagged,
                            );
                          },
                        ),
                        if (!shrink)
                          UserWidget.info(
                            userKey: node.createdBy,
                            baseFontSize: baseFontSize,
                            trim: 20,
                            redirect: true,
                          )
                        else
                          UserWidget.infoSmall(
                            key: ValueKey("${node.createdBy}-with-small-size"),
                            userKey: node.createdBy,
                            baseFontSize: baseFontSize,
                            trim: 16,
                            redirect: true,
                          ),
                      ],
                    )
                  : !shrink
                      ? UserWidget(
                          userKey: node.createdBy,
                          baseFontSize: baseFontSize,
                          trim: 20,
                          redirect: true,
                        )
                      : UserWidget.small(
                          key: ValueKey("${node.createdBy}-with-small-size"),
                          userKey: node.createdBy,
                          baseFontSize: baseFontSize,
                          trim: 16,
                          redirect: true,
                        ),
              Column(
                spacing: Constants.gap * 0.25,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!superShrink)
                    Text(
                      displayDateDifference(
                        node.createdOn,
                        format: shrink ? "d MMM y" : "EEEE, d MMM y",
                      ),
                      style: TextStyle(
                        fontSize: Constants.smallFontSize * shrinkFactor,
                      ),
                    ),
                  if (usersTagged.isNotEmpty)
                    InkWell(
                      onTap: () {
                        showTaggedUsers(
                          context: context,
                          usersTagged: usersTagged,
                        );
                      },
                      child: Row(
                        spacing: Constants.gap * 0.25,
                        children: [
                          Icon(
                            Icons.groups,
                            color: currTheme.primary,
                            size: Constants.iconButtonSize * 0.5,
                          ),
                          if (!superShrink)
                            Text(
                              "Tagged Users",
                              style: TextStyle(
                                color: currTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: Constants.smallFontSize,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
