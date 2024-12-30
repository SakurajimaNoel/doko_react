import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
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
    this.recordLimit = Constants.videoDuration,
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
  })  : assert(text != null || icon != null,
            "Need either text or an Icon to create media selection trigger."),
        picker = ImagePicker(),
        image = false,
        video = false,
        recordLimit = Duration(seconds: 0),
        mediaOnly = true;

  /// text used to trigger media selection
  /// either text or icon should be given
  /// if both are present icon is prioritised
  final String? text;

  /// icon used to trigger media selection
  final Icon? icon;

  /// callback to call when media file is selected
  final ValueSetter<List<XFile>> onSelection;

  /// allowing multiple media images to be selected
  /// default is false
  final bool multiple;

  /// to limit the selection of images
  /// default is 10
  final int multipleLimit;

  /// used for disabling display button
  /// default is false
  final bool disabled;

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
    if (multipleLimit > 0) selectVideoFromCamera();
  }

  void handleGallery(BuildContext context) {
    if (multiple && multipleLimit > 1) {
      selectMultipleImagesFromGallery();
    } else if (multipleLimit > 0) {
      selectImageFromGallery();
    }
  }

  void handleCamera(BuildContext context) {
    if (multipleLimit > 0) selectImageFromCamera();
  }

  /// this will be only used for real time communication
  /// when using this in post and selecting multiple video file
  /// this causes issue because only 1 video can be processed
  /// at a time
  void handleMedia(BuildContext context) {
    if (multiple && multipleLimit > 1) {
      selectMultipleMediaFilesFromGallery();
    } else if (multipleLimit > 0) {
      selectMediaFileFromGallery();
    }
  }

  void selectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          height: Constants.height * 15,
          padding: EdgeInsets.all(Constants.padding),
          child: GridView.count(
            mainAxisSpacing: Constants.gap,
            crossAxisSpacing: Constants.gap,
            childAspectRatio: 4 / 1,
            crossAxisCount: 2,
            children: [
              if (image) ...[
                SizedBox(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      handleGallery(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text("Select image"),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    handleCamera(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Take picture"),
                )
              ],
              if (video) ...[
                FilledButton.tonalIcon(
                  onPressed: () {
                    handleVideo(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.video_collection),
                  label: const Text("Select video"),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    handleVideoCapture(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text("Record video"),
                ),
              ],
            ],
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
        child: Text(text!),
      );
    }

    return IconButton.filled(
      onPressed: disabled ? null : action,
      icon: icon!,
    );
  }

  Future<void> selectVideoFromGallery() async {
    final XFile? selectedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (selectedVideo == null) return;
    onSelection([selectedVideo]);
  }

  Future<void> selectVideoFromCamera() async {
    final XFile? capturedVideo = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: recordLimit,
    );

    if (capturedVideo == null) return;
    onSelection([capturedVideo]);
  }

  Future<void> selectMultipleImagesFromGallery() async {
    final List<XFile> selectedImages = await picker.pickMultiImage(
      limit: multipleLimit,
    );

    if (selectedImages.isEmpty) return;
    onSelection(selectedImages);
  }

  Future<void> selectImageFromGallery() async {
    final XFile? selectedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedImage == null) return;
    onSelection([selectedImage]);
  }

  Future<void> selectImageFromCamera() async {
    final XFile? capturedImage = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (capturedImage == null) return;
    onSelection([capturedImage]);
  }

  Future<void> selectMultipleMediaFilesFromGallery() async {
    final List<XFile> selectedMediaFiles = await picker.pickMultipleMedia(
      limit: multipleLimit,
    );

    if (selectedMediaFiles.isEmpty) return;
    onSelection(selectedMediaFiles);
  }

  Future<void> selectMediaFileFromGallery() async {
    final XFile? selectedMedia = await picker.pickMedia();

    if (selectedMedia == null) return;
    onSelection([selectedMedia]);
  }
}
