part of 'profile_widget.dart';

class _ProfileUserWidget extends StatelessWidget {
  const _ProfileUserWidget({
    required this.username,
    required this.self,
    required this.onShare,
  });

  final String username;
  final bool self;
  final VoidCallback onShare;

  List<Widget> appBarActions(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (!self) {
      return [
        TextButton(
          onPressed: onShare,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Share",
            style: TextStyle(
              color: currTheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: Constants.fontSize,
            ),
          ),
        ),
      ];
    }

    return [
      IconButton(
        onPressed: () {
          context.pushNamed(RouterConstants.settings);
        },
        color: currTheme.onSurface,
        icon: const Icon(
          Icons.settings,
        ),
        tooltip: "Settings",
      ),
      const SignOutButton(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();
    final key = generateUserNodeKey(username);

    final currTheme = Theme.of(context).colorScheme;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final height = min(constraints.crossAxisExtent,
            MediaQuery.sizeOf(context).height - Constants.height * 1.125);
        final width = constraints.viewportMainAxisExtent;

        return SliverAppBar(
          pinned: true,
          expandedHeight: height,
          title: AutoHeading(
            username,
            color: currTheme.onSurface,
            size: Constants.heading3,
            minFontSize: Constants.heading4,
            maxLines: 1,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: Constants.gap,
          ),
          actions: appBarActions(context),
          flexibleSpace: FlexibleSpaceBar(
            background:
                BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
              buildWhen: (previousState, state) {
                return (state is UserToUserActionUpdateProfileState &&
                    state.username == username);
              },
              builder: (context, state) {
                final user = graph.getValueByKey(key)! as UserEntity;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    user.profilePicture.bucketPath.isNotEmpty
                        ? _ProfilePicture(
                            key: ObjectKey({
                              width,
                              height,
                            }),
                            username: username,
                            height: height,
                            width: width,
                          )
                        : Container(
                            color: currTheme.onSecondary,
                            child: Icon(
                              Icons.person,
                              size: height,
                            ),
                          ),
                    ProfilePictureFilter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: Constants.padding * 0.25,
                        ),
                        child: AutoHeading(
                          user.name,
                          color: currTheme.onSurface,
                          size: Constants.heading2,
                          minFontSize: Constants.heading3,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture({
    super.key,
    required this.username,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;
  final String username;

  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();
    final String userKey = generateUserNodeKey(username);
    final UserEntity user = graph.getValueByKey(userKey)! as UserEntity;

    bool filterEnable = width != height;
    double blurRadius = 16;

    return Stack(
      children: [
        if (filterEnable)
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurRadius,
                  sigmaY: blurRadius,
                ),
                child: CachedNetworkImage(
                  memCacheHeight: Constants.profileCacheHeight,
                  cacheKey: user.profilePicture.bucketPath,
                  imageUrl: user.profilePicture.accessURI,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: LoadingWidget.small(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  height: height,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: CachedNetworkImage(
            memCacheHeight: Constants.profileCacheHeight,
            cacheKey: user.profilePicture.bucketPath,
            imageUrl: user.profilePicture.accessURI,
            fit: BoxFit.fitHeight,
            placeholder: (context, url) => const Center(
              child: LoadingWidget.small(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ],
    );
  }
}
