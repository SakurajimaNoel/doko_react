import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:flutter/material.dart';

import '../../../core/data/storage.dart';
import '../../../core/helpers/enum.dart';
import '../../../core/widgets/loader_button.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  final String userProfileImg;

  const PostWidget({
    required Key key,
    required this.post,
    this.userProfileImg = "",
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late final PostModel _post;

  String _userProfileImg = "";

  @override
  void initState() {
    super.initState();

    _post = widget.post;
    _userProfileImg = widget.userProfileImg;

    if (_userProfileImg.isEmpty) {
      // fetch profile image
      _fetchUserProfileImage(_post.createdBy.profilePicture);
    }
  }

  Future<void> _fetchUserProfileImage(String path) async {
    if (path.isEmpty) {
      return;
    }

    var result = await StorageActions.getDownloadUrl(path);

    if (result.status == ResponseStatus.success) {
      if (mounted) {
        setState(() {
          _userProfileImg = result.value;
        });
      }
    }
  }

  Widget _userInfo() {
    return Row(
      children: [
        _userProfileImg.isEmpty
            ? const CircleAvatar(
                child: Icon(Icons.person),
              )
            : CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    cacheKey: _post.createdBy.profilePicture,
                    imageUrl: _userProfileImg,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
        const SizedBox(
          width: Constants.gap * 0.5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_post.createdBy.name),
            Text(
              // TODO: make it clickable
              "@${_post.createdBy.username}",
              style: const TextStyle(
                fontSize: Constants.smallFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }

  // Future<void> _fetchContentImage(String path, int index) async {
  //   if (path.isEmpty) {
  //     return;
  //   }
  //
  //   var result = await StorageActions.getDownloadUrl(path);
  //   if (result.status == ResponseStatus.success) {
  //     if (mounted) {
  //       setState(() {
  //         _content[index] = result.value;
  //       });
  //     }
  //   }
  // }

  Widget _postContentItem(BuildContext context, int index) {
    // if (_content[index].isEmpty) {
    //   _fetchContentImage(_post.content[index], index);
    // }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Constants.height * 18,
      // child: Text("content"),
      child: _post.signedContent[index].isEmpty
          ? const Center(
              child: LoaderButton(),
            )
          : CachedNetworkImage(
              cacheKey: _post.content[index],
              fit: BoxFit.cover,
              imageUrl: _post.signedContent[index],
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              height: Constants.height * 18,
            ),
    );
  }

  Widget _postContent() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemCount: _post.content.length,
      itemBuilder: (BuildContext context, int index) =>
          _postContentItem(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: Constants.gap * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // post metadata
            padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _userInfo(),
                Text(
                  DisplayText.displayDateDiff(_post.createdOn),
                  style: const TextStyle(
                    fontSize: Constants.smallFontSize,
                  ),
                ),
              ],
            ),
          ),
          if (_post.content.isNotEmpty) ...[
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            SizedBox(height: 320, child: _postContent()),
          ],
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          // caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            child: Text(_post.caption),
          ),
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            child: Row(
              children: [
                Text("Post actions here"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
