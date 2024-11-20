import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/archive/core/configs/router/router_constants.dart';
import 'package:doko_react/archive/core/data/cache.dart';
import 'package:doko_react/archive/core/data/storage.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/helpers/media_type.dart';
import 'package:doko_react/archive/core/provider/user_preferences_provider.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/widgets/loader/loader_button.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreatePostPublishPage extends StatefulWidget {
  final List<PostContent> postContent;
  final String postId;

  const CreatePostPublishPage({
    super.key,
    required this.postContent,
    required this.postId,
  });

  @override
  State<CreatePostPublishPage> createState() => _CreatePostPublishPageState();
}

class _CreatePostPublishPageState extends State<CreatePostPublishPage> {
  final StorageActions storage = StorageActions(storage: Amplify.Storage);
  late final List<PostContent> _postContent;

  late final UserPreferencesProvider userPreferencesProvider;
  late final UserProvider userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  bool _uploading = false;
  String _caption = "";

  @override
  void initState() {
    super.initState();

    _postContent = widget.postContent;
    userPreferencesProvider = context.read<UserPreferencesProvider>();
    userProvider = context.read<UserProvider>();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  Future<void> _updateGraph(List<String> postContentPath) async {
    var result = await _userGraphqlService.userCreatePost(
      widget.postId,
      caption: _caption,
      content: postContentPath,
      username: userProvider.username,
    );

    setState(() {
      _uploading = false;
    });

    if (result == ResponseStatus.error) {
      String message =
          "Oops! Something went wrong when creating post. Please try again later.";
      _showMessage(message);

      // clean up
      for (final path in postContentPath) {
        storage.deleteFile(path);
      }

      return;
    }

    userPreferencesProvider.needsProfileRefresh();

    // navigate to user feed
    String message = "Successfully created new post.";
    _showMessage(message);
    _handleSuccess();
  }

  void _handleSuccess() {
    context.goNamed(RouterConstants.userFeed);
  }

  Future<void> _handlePostUpload() async {
    if (_caption.isEmpty && _postContent.isEmpty) {
      String message =
          "Your post needs either content or a caption. Please add at least one to proceed.";
      _showMessage(message);
      return;
    }

    setState(() {
      _uploading = true;
    });

    // upload file
    List<Future<StorageResult>> fileUploadFuture = [];
    List<String> postContentPath = [];
    for (final item in _postContent) {
      if (item.type == MediaTypeValue.thumbnail ||
          item.type == MediaTypeValue.unknown) continue;

      fileUploadFuture.add(storage.uploadFile(item.file!, item.path));
      Cache.addFileToCache(item.file!.path, item.path);
    }

    List<StorageResult> results = await Future.wait(fileUploadFuture);

    for (final result in results) {
      if (result.status == ResponseStatus.error) continue;

      postContentPath.add(result.value);
    }

    if (_postContent.isNotEmpty && postContentPath.isEmpty) {
      setState(() {
        _uploading = false;
      });
      String message =
          "Oops! Something went wrong when uploading media items. Please try again later.";
      _showMessage(message);
      return;
    }

    // update graph
    _updateGraph(postContentPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish post"),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, var result) {
          if (didPop) return;

          if (_uploading) {
            String message =
                "Your post is almost there! Please let it finish uploading before navigating away.";
            _showMessage(message);
            return;
          }

          context.pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFormField(
                enabled: !_uploading,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Caption",
                  hintText: "Caption here...",
                ),
                onChanged: (String? value) {
                  _caption = value ?? "";
                },
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                minLines: 5,
                maxLength: 1000,
              ),
              FilledButton(
                onPressed: _uploading ? null : _handlePostUpload,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    Constants.buttonWidth,
                    Constants.buttonHeight,
                  ),
                ),
                child: _uploading ? const LoaderButton() : const Text("Upload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
