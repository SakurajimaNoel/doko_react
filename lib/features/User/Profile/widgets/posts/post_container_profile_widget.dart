import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/post_widget.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostContainerProfileWidget extends StatefulWidget {
  final ProfilePostInfo postInfo;
  final UserModel user;

  const PostContainerProfileWidget({
    super.key,
    required this.postInfo,
    required this.user,
  });

  @override
  State<PostContainerProfileWidget> createState() =>
      _PostContainerProfileWidgetState();
}

class _PostContainerProfileWidgetState
    extends State<PostContainerProfileWidget> {
  late final ProfilePostInfo postInfo;
  late final UserModel user;
  late final UserProvider userProvider;

  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  bool loading = false;

  late List<ProfilePostModel> posts;

  @override
  void initState() {
    super.initState();

    postInfo = widget.postInfo;
    user = widget.user;

    posts = postInfo.posts;
    userProvider = context.read<UserProvider>();
  }

  Future<void> _fetchMorePosts() async {
    // only call this function when has next page
    String username = user.username;
    String cursor = postInfo.info.endCursor!;

    var postResponse = await userGraphqlService.getPostsByUsername(
      username,
      cursor: cursor,
      currentUsername: userProvider.username,
    );

    loading = false;

    if (postResponse.status == ResponseStatus.error) {
      String message = "Error fetching more user posts";
      _handleError(message);
      return;
    }

    if (postResponse.postInfo == null) {
      postInfo.info.updateInfo(null, false);
      return;
    }

    postInfo.addPosts(postResponse.postInfo!.posts);
    setState(() {
      posts = postInfo.posts;
    });
    postInfo.info.updateInfo(postResponse.postInfo!.info.endCursor,
        postResponse.postInfo!.info.hasNextPage);
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

  Widget _buildItem(BuildContext context, int index) {
    if (index >= posts.length) {
      // fetch more posts if available
      if (!postInfo.info.hasNextPage) {
        // no more posts available
        return Center(
          child: Text(
            "${user.name} has no more posts.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      if (!loading) {
        loading = true;
        _fetchMorePosts();
      }

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    PostModel postItem =
        PostModel.fromProfilePost(post: posts[index], createdBy: user);

    void likeCallback(bool like) {
      posts[index].updateUserLike(like);
    }

    void currentItemCallback(int item) {
      posts[index].updatePostInitialItem(item);
    }

    return PostWidget(
      post: postItem,
      handlePostLike: likeCallback,
      handlePostDisplayItem: currentItemCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "${user.name} has not uploaded any posts.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: posts.length + 1,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: Constants.gap * 2.5,
        );
      },
    );
  }
}
