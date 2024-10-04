import 'package:doko_react/core/helpers/media_type.dart';
import 'package:flutter/material.dart';

class CreatePostPublishPage extends StatefulWidget {
  final List<PostContent> postContent;

  const CreatePostPublishPage({
    super.key,
    required this.postContent,
  });

  @override
  State<CreatePostPublishPage> createState() => _CreatePostPublishPageState();
}

class _CreatePostPublishPageState extends State<CreatePostPublishPage> {
  late final List<PostContent> _postContent;

  @override
  void initState() {
    super.initState();

    _postContent = widget.postContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish post"),
      ),
      body: Text("rohan ${_postContent.length}"),
    );
  }
}
