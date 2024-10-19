import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/post_widget.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';

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
  late final ProfilePostInfo _postInfo;
  late final UserModel _user;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  bool _loading = false;

  late List<ProfilePostModel> _posts;

  @override
  void initState() {
    super.initState();

    _postInfo = widget.postInfo;
    _user = widget.user;

    _posts = _postInfo.posts;
  }

  Future<void> _fetchMorePosts() async {
    // only call this function when has next page
    String id = _user.id;
    String cursor = _postInfo.info.endCursor!;

    var postResponse = await _userGraphqlService.getPostsByUserId(id, cursor);

    _loading = false;

    if (postResponse.status == ResponseStatus.error) {
      String message = "Error fetching more user posts";
      _handleError(message);
      return;
    }

    if (postResponse.postInfo == null) {
      _postInfo.info.updateInfo(null, false);
      return;
    }

    _postInfo.addPosts(postResponse.postInfo!.posts);
    setState(() {
      _posts = _postInfo.posts;
    });
    _postInfo.info.updateInfo(postResponse.postInfo!.info.endCursor,
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

  void _updatePostLike(bool like, int index) {
    _posts[index].updateUserLike(like);
  }

  void _postCurrentDisplayItem(int index, int item) {
    _posts[index].updatePostInitialItem(item);
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index >= _posts.length) {
      // fetch more posts if available
      if (!_postInfo.info.hasNextPage) {
        // no more posts available
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Constants.padding * 2,
          ),
          child: Center(
            child: Text(
              "${_user.name} has no more posts.",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      if (!_loading) {
        _loading = true;
        _fetchMorePosts();
      }
      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: Constants.padding,
        ),
        child: const Center(
          child: LoaderButton(),
        ),
      );
    }

    PostModel postItem =
        PostModel.fromProfilePost(post: _posts[index], createdBy: _user);

    void likeCallback(bool like) {
      _updatePostLike(like, index);
    }

    void currentItemCallback(int item) {
      _postCurrentDisplayItem(index, item);
    }

    return PostWidget(
      post: postItem,
      handlePostLike: likeCallback,
      handlePostDisplayItem: currentItemCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "${_user.name} has not uploaded any posts.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: _posts.length + 1,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index),
    );
  }
}
