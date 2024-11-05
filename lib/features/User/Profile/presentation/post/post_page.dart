import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/comment_input.dart';
import 'package:doko_react/features/User/Profile/widgets/posts/post_widget.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  final PostModel post;

  const PostPage({
    super.key,
    required this.post,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  double bottomSheetHeight = 0;
  final bottomSheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sheetHeight = bottomSheetKey.currentContext?.size?.height ?? 0;
      safePrint("sheet height");
      safePrint(sheetHeight);
      if (sheetHeight != bottomSheetHeight) {
        setState(() {
          bottomSheetHeight = sheetHeight;
        });
      }
    });
  }

  void handlePostLike(bool value) {
    widget.post.updateUserLike(value);
  }

  void handlePostDisplayItem(int value) {
    widget.post.updatePostInitialItem(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.caption),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: Constants.gap,
              ),
              children: [
                PostWidget(
                  post: widget.post,
                  handlePostLike: handlePostLike,
                  handlePostDisplayItem: handlePostDisplayItem,
                  location: PostLocation.page,
                ),
              ],
            ),
          ),
          const CommentInput()
        ],
      ),
    );
  }
}
