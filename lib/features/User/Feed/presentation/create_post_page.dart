import 'dart:io';

import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/core/widgets/image_picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/widgets/general/bullet_list.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> postContentInfo = [
      "You can add up to ${Constants.postLimit} media items per post.",
      "Keep your videos under ${Constants.videoDuration.inSeconds} seconds. Longer videos will be automatically trimmed."
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Create new post"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeading(
                "Just a heads up:",
                size: Constants.fontSize,
              ),
              const SizedBox(
                height: Constants.gap * 0.5,
              ),
              BulletList(postContentInfo),
              const Expanded(
                child: _PostContentWidget(),
              )
            ],
          ),
        ));
  }
}

class _PostContentWidget extends StatefulWidget {
  const _PostContentWidget({super.key});

  @override
  State<_PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<_PostContentWidget> {
  List<PostContent> _content = [];

  void _handleMediaInfo(XFile item) {
    MediaTypeValue type = MediaType.getMediaType(item.path);
    File file = File(item.path);

    if (type == MediaTypeValue.video) return;

    _content.add(PostContent(
      type: type,
      file: file,
    ));
    setState(() {});
  }

  void onSelection(List<XFile> selectedFiles) {
    // handle selected files
    for (var item in selectedFiles) {
      _handleMediaInfo(item);
    }
  }

  Widget _mediaSelect() {
    String displayText = "Select media content.";
    return ImagePickerWidget(
      displayText,
      onSelection: onSelection,
      multiple: true,
      video: true,
      multipleLimit: Constants.postLimit - _content.length,
      disabled: _content.length == Constants.postLimit,
    );
  }

  Widget _postItemWrapper({required Widget item, required int index}) {
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;

    return SizedBox(
      width: width,
      child: item,
    );
  }

  List<Widget> _handleDisplayMedia() {
    List<Widget> mediaWidgets = [];

    for (int i = 0; i < _content.length; i++) {
      var item = _content[i];
      var type = item.type;

      switch (type) {
        case MediaTypeValue.image:
          mediaWidgets.add(
            _postItemWrapper(
              item: Image.file(
                item.file,
                fit: BoxFit.cover,
                cacheHeight: Constants.postCacheHeight,
              ),
              index: 0,
            ),
          );
          break;
        case MediaTypeValue.video:
          mediaWidgets.add(
            _postItemWrapper(
              item: VideoPlayer(path: item.file.path),
              index: 0,
            ),
          );
          break;
        default:
          mediaWidgets.add(
            Container(
              color: Colors.red,
            ),
          );
          break;
      }
    }

    return mediaWidgets;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = width * (1 / Constants.postContainer);
    width = width - Constants.padding * 2;

    var currTheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: Constants.gap,
            ),
            SizedBox(
              height: height,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                children: [
                  if (_content.isNotEmpty) ..._handleDisplayMedia(),
                  if (_content.length < Constants.postLimit)
                    Container(
                      width: width,
                      color: currTheme.outlineVariant,
                      child: Center(
                        child: _mediaSelect(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
            Text(
                "Selected media items: ${_content.length} / ${Constants.postLimit}."),
          ],
        ),
        FilledButton(
          onPressed: () {
            Map<String, dynamic> data = {
              "postContent": _content,
            };

            context.pushNamed(
              RouterConstants.postPublish,
              extra: data,
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(
              Constants.buttonWidth,
              Constants.buttonHeight,
            ),
          ),
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
