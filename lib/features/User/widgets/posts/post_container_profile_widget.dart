import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/widgets/loader_button.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/features/User/widgets/posts/post_widget.dart';
import 'package:flutter/material.dart';

class PostContainerProfileWidget extends StatefulWidget {
  final ProfilePostInfo postInfo;
  final UserModel user;
  final String img;

  const PostContainerProfileWidget({
    super.key,
    required this.postInfo,
    required this.user,
    required this.img,
  });

  @override
  State<PostContainerProfileWidget> createState() =>
      _PostContainerProfileWidgetState();
}

class _PostContainerProfileWidgetState extends State<PostContainerProfileWidget>
    with AutomaticKeepAliveClientMixin {
  late final ProfilePostInfo _postInfo;
  late final UserModel _user;
  late final String _profile;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  bool _loading = false;
  String _errorMessage = "";
  late List<ProfilePostModel> _posts;

  @override
  void initState() {
    super.initState();

    _postInfo = widget.postInfo;
    _user = widget.user;
    _profile = widget.img;

    _posts = _postInfo.posts;
  }

  Future<void> _fetchMorePosts() async {
    // only call this function when has next page
    String id = _user.id;
    String cursor = _postInfo.info.endCursor!;

    var postResponse = await _userGraphqlService.getPostsByUserId(id, cursor);

    _loading = false;

    if (postResponse.status == ResponseStatus.error) {
      setState(() {
        _errorMessage = "Error fetching user posts.";
      });
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

  Widget _buildItem(BuildContext context, int index) {
    if (index >= _posts.length) {
      // fetch more posts if available
      if (!_postInfo.info.hasNextPage) {
        // no more posts available
        return const Padding(
          padding: EdgeInsets.only(
            bottom: Constants.padding,
          ),
          child: Center(
            child: Text(
              "User has no more posts.",
              style: TextStyle(
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
      return const Center(
        child: LoaderButton(),
      );
    }

    PostModel postItem =
        PostModel.fromProfilePost(post: _posts[index], createdBy: _user);
    return PostWidget(
      post: postItem,
      profileImage: _profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: Constants.padding,
        ),
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

    return ListView.builder(
      itemCount: _posts.length + 1,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(context, index),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
