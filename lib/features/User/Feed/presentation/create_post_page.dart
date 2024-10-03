import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/widgets/image_picker/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  List<_PostContent> content = [];

  void onSelection(List<XFile> mediaFiles) async {
    safePrint(await mediaFiles[0].length());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new post"),
      ),
      body: ImagePickerWidget(
        "",
        icon: const Icon(Icons.add),
        onSelection: onSelection,
        multiple: true,
        video: true,
      ),
    );
  }
}

class _PostContent {
  final MediaType type;
  final File file;

  _PostContent({
    required this.type,
    required this.file,
  });
}
