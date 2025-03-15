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
        final height =
            min(constraints.crossAxisExtent, MediaQuery.sizeOf(context).height);
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

/// enhanced enum for picture alignment
enum FaceAlignment {
  top(
    alignment: Alignment.topCenter,
  ),
  center(
    alignment: Alignment.center,
  ),
  bottom(
    alignment: Alignment.bottomCenter,
  );

  const FaceAlignment({
    required this.alignment,
  });

  final Alignment alignment;
}

class _ProfilePicture extends StatefulWidget {
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
  State<_ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<_ProfilePicture> {
  final UserGraph graph = UserGraph();
  late final String username = widget.username;
  late final String userKey = generateUserNodeKey(username);
  late final UserEntity user = graph.getValueByKey(userKey)! as UserEntity;

  @override
  void initState() {
    super.initState();

    detectFacePosition();
  }

  Future<String?> downloadUserProfilePicture(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      String path = "${tempDir.path}/${user.profilePicture.bucketPath}";

      if (await File(path).exists()) return path;

      final directory = File(path).parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true); // Ensure the directory exists
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      debugPrint("Error downloading image: $e");
    }
    return null;
  }

  Future<void> detectFacePosition() async {
    String? image =
        await downloadUserProfilePicture(user.profilePicture.accessURI);
    if (image == null) return;

    if (user.profileHeight == null) {
      final userProfile = await compute(img.decodeImageFile, image);
      if (userProfile == null) return;

      user.profileHeight = userProfile.height;
      // graph.addEntity(userKey, user);
    }

    // Get image height from metadata
    final imageHeight = user.profileHeight!;

    if (user.faces == null) {
      final InputImage inputProfile = InputImage.fromFile(File(image));
      final faceDetector =
          FaceDetector(options: FaceDetectorOptions(enableContours: false));

      final List<Face> faces = await faceDetector.processImage(inputProfile);
      await faceDetector.close();
      user.faces = faces;
      // graph.addEntity(userKey, user);
    }

    final faces = user.faces!;
    if (faces.isEmpty) return;

    Face face = faces.first;

    // Normalize face Y position
    final faceCenterY = face.boundingBox.center.dy;
    final relativePosition = faceCenterY / imageHeight;

    FaceAlignment alignment;
    // Categorize position
    if (relativePosition < 0.33) {
      alignment = FaceAlignment.top;
    } else if (relativePosition < 0.66) {
      alignment = FaceAlignment.center;
    } else {
      alignment = FaceAlignment.bottom;
    }

    if (user.faceAlignment != alignment) {
      user.faceAlignment = alignment;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      memCacheHeight: Constants.profileCacheHeight,
      cacheKey: user.profilePicture.bucketPath,
      imageUrl: user.profilePicture.accessURI,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: LoadingWidget.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: widget.height,
      width: widget.width,
      alignment:
          user.faceAlignment?.alignment ?? FaceAlignment.center.alignment,
    );
  }
}
