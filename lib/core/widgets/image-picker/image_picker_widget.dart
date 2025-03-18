import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/preferences/preferences_bloc.dart';
import 'package:doko_react/core/utils/media/image/image.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  ImagePickerWidget({
    this.text,
    this.icon,
    super.key,
    required this.onSelection,
    this.multiple = false,
    this.multipleLimit = 10,
    this.disabled = false,
    this.image = true,
    this.video = false,
    this.adding = false,
    this.selectionStatusChange,
    this.recordLimit = Constants.videoDurationContent,
    this.disableImageCompression = false,
  })  : assert(text != null || icon != null,
            "Need either text or an Icon to create media selection trigger."),
        picker = ImagePicker(),
        mediaOnly = false;

  ImagePickerWidget.media({
    this.text,
    this.icon,
    super.key,
    required this.onSelection,
    this.multiple = false,
    this.multipleLimit = 10,
    this.disabled = false,
    this.adding = false,
    this.selectionStatusChange,
    this.disableImageCompression = false,
  })  : assert(text != null || icon != null,
            "Need either text or an Icon to create media selection trigger."),
        picker = ImagePicker(),
        image = false,
        video = false,
        recordLimit = const Duration(seconds: 0),
        mediaOnly = true;

  /// text used to trigger media selection
  /// either text or icon should be given
  /// if both are present icon is prioritised
  final String? text;

  /// icon used to trigger media selection
  final Icon? icon;

  /// callback to call when media file is selected
  final ValueSetter<List<String>> onSelection;

  /// allowing multiple media images to be selected
  /// default is false
  final bool multiple;

  /// to limit the selection of images
  /// default is 10
  final int multipleLimit;

  /// used for disabling display button
  /// default is false
  final bool disabled;

  /// used when selecting user profile
  /// as compression will happen after cropping
  final bool disableImageCompression;

  /// used when images are being processed
  final bool adding;

  /// this is used to update status of adding media files
  final ValueSetter<bool>? selectionStatusChange;

  /// to allow selecting video files
  /// default is false
  final bool video;
  final bool image;

  /// to allow selecting both video and image
  /// from user gallery
  final bool mediaOnly;

  /// Image picker initialization
  final ImagePicker picker;

  /// Video capture duration
  final Duration recordLimit;

  void handleVideo(BuildContext context) {
    if (multipleLimit > 0) selectVideoFromGallery();
  }

  void handleVideoCapture(BuildContext context) {
    if (multipleLimit > 0) {
      selectVideoFromCamera(
          context.read<PreferencesBloc>().state.saveCapturedMedia);
    }
  }

  void handleGallery(BuildContext context) {
    if (multiple && multipleLimit > 1) {
      selectMultipleImagesFromGallery();
    } else if (multipleLimit > 0) {
      selectImageFromGallery();
    }
  }

  void handleCamera(BuildContext context) {
    if (multipleLimit > 0) {
      selectImageFromCamera(
          context.read<PreferencesBloc>().state.saveCapturedMedia);
    }
  }

  /// this will be only used for real time communication
  /// when using this in post and selecting multiple video file
  /// this causes issue because only 1 video can be processed
  /// at a time
  void handleMedia(BuildContext context) {
    if (adding) {
      showInfo("Adding your images... just a moment!");
      return;
    }

    if (multiple && multipleLimit > 1) {
      selectMultipleMediaFilesFromGallery();
    } else if (multipleLimit > 0) {
      selectMediaFileFromGallery();
    }
  }

  void selectOptions(BuildContext context) {
    if (adding) {
      showInfo("Adding your images... just a moment!");
      return;
    }

    final width = MediaQuery.sizeOf(context).width;
    final currTheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          height: Constants.height * 15,
          width: width,
          padding: const EdgeInsets.all(Constants.padding),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: Constants.gap * 1.75,
              runSpacing: Constants.gap * 1.75,
              children: [
                if (image)
                  _IconButtonWithBottomLabel(
                    label: "Select image",
                    onPressed: () {
                      handleGallery(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.photo_library,
                      color: currTheme.primary,
                    ),
                  ),
                if (video)
                  _IconButtonWithBottomLabel(
                    label: "Select video",
                    onPressed: () {
                      handleVideo(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.video_collection,
                      color: currTheme.primary,
                    ),
                  ),
                if (image)
                  _IconButtonWithBottomLabel(
                    label: "Take picture",
                    onPressed: () {
                      handleCamera(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.photo_camera,
                      color: currTheme.secondary,
                    ),
                  ),
                if (video)
                  _IconButtonWithBottomLabel(
                    label: "Record video",
                    onPressed: () {
                      handleVideoCapture(context);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.videocam,
                      color: currTheme.secondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback action =
        mediaOnly ? () => handleMedia(context) : () => selectOptions(context);
    if (icon == null) {
      return TextButton(
        onPressed: disabled ? null : action,
        child: adding
            ? const LoadingWidget.small()
            : Text(
                text!,
                textAlign: TextAlign.center,
              ),
      );
    }

    return IconButton.filled(
      onPressed: disabled ? null : action,
      icon: adding ? const LoadingWidget.small() : icon!,
    );
  }

  Future<void> compressSelectedImages(List<String> images) async {
    if (disableImageCompression) {
      onSelection(images);
      return;
    }

    if (selectionStatusChange != null) selectionStatusChange!(true);
    int batchSize = 5;
    int len = images.length;

    for (int i = 0; i < len; i += batchSize) {
      final batch = images.sublist(
        i,
        i + batchSize > len ? len : i + batchSize,
      );

      onSelection(await compute(compressImages, batch));
    }
    if (selectionStatusChange != null) selectionStatusChange!(false);
  }

  Future<void> handleSaveOnCapture(
    String path, {
    required bool isVideo,
  }) async {
    bool permission = await Gal.requestAccess(toAlbum: true);
    if (!permission) showError(GalExceptionType.accessDenied.message);

    try {
      if (isVideo) {
        await Gal.putVideo(
          path,
          album: "Doki",
        );
      } else {
        await Gal.putImage(
          path,
          album: "Doki",
        );
      }
    } on GalException catch (e) {
      showError(e.type.message);
    } catch (_) {
      showError(Constants.errorMessage);
    }
  }

  Future<void> selectVideoFromGallery() async {
    final XFile? selectedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (selectedVideo == null) return;
    onSelection([selectedVideo.path]);
  }

  Future<void> selectVideoFromCamera(bool saveOnCapture) async {
    final XFile? capturedVideo = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: recordLimit,
    );

    if (capturedVideo == null) return;
    if (saveOnCapture) {
      handleSaveOnCapture(
        capturedVideo.path,
        isVideo: true,
      );
    }

    onSelection([capturedVideo.path]);
  }

  Future<void> selectMultipleImagesFromGallery() async {
    final List<XFile> selectedImages = await picker.pickMultiImage(
      limit: multipleLimit,
    );

    if (selectedImages.isEmpty) return;
    List<String> selected = [];
    for (var media in selectedImages) {
      selected.add(media.path);
    }
    compressSelectedImages(selected);
  }

  Future<void> selectImageFromGallery() async {
    final XFile? selectedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage == null) return;
    compressSelectedImages([selectedImage.path]);
  }

  Future<void> selectImageFromCamera(bool saveOnCapture) async {
    final XFile? capturedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (capturedImage == null) return;
    if (saveOnCapture) {
      handleSaveOnCapture(
        capturedImage.path,
        isVideo: false,
      );
    }
    compressSelectedImages([capturedImage.path]);
  }

  Future<void> selectMultipleMediaFilesFromGallery() async {
    final List<XFile> selectedMediaFiles = await picker.pickMultipleMedia(
      limit: multipleLimit,
    );

    if (selectedMediaFiles.isEmpty) return;
    List<String> selected = [];
    for (var media in selectedMediaFiles) {
      selected.add(media.path);
    }
    onSelection(selected);
  }

  Future<void> selectMediaFileFromGallery() async {
    final XFile? selectedMedia = await picker.pickMedia();

    if (selectedMedia == null) return;
    onSelection([selectedMedia.path]);
  }
}

class _IconButtonWithBottomLabel extends StatelessWidget {
  const _IconButtonWithBottomLabel({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
        _IconLabel(label),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: Constants.smallFontSize,
      ),
      textAlign: TextAlign.center,
    );
  }
}
