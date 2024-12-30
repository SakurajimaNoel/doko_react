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
    this.video = false,
    this.recordLimit = Constants.videoDuration,
  })  : assert(text != null || icon != null,
            "Need either text or an Icon to create media selection trigger."),
        picker = ImagePicker();

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

  /// Image picker initialization
  final ImagePicker picker;

  /// Video capture duration
  final Duration recordLimit;

  void handleVideo(BuildContext context) {
    if (multipleLimit > 0) selectVideoFromGallery();
    Navigator.pop(context);
  }

  void handleVideoCapture(BuildContext context) {
    if (multipleLimit > 0) selectVideoFromCamera();
    Navigator.pop(context);
  }

  void handleGallery(BuildContext context) {
    if (multiple && multipleLimit > 1) {
      selectMultipleImagesFromGallery();
    } else if (multipleLimit > 0) {
      selectImageFromGallery();
    }
    Navigator.pop(context);
  }

  void handleCamera(BuildContext context) {
    if (multipleLimit > 0) selectImageFromCamera();
    Navigator.pop(context);
  }

  void selectOptions(BuildContext context) {
    bool showLabel = !video;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: Constants.height * 15,
          width: double.infinity,
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              FilledButton.tonalIcon(
                onPressed: () {
                  handleGallery(context);
                },
                icon: const Icon(Icons.photo),
                label: const Text("Gallery"),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  handleCamera(context);
                },
                icon: const Icon(Icons.photo_camera),
                label: const Text("Take picture"),
              ),
              if (video) ...[
                FilledButton.tonalIcon(
                  onPressed: () {
                    handleVideo(context);
                  },
                  icon: const Icon(Icons.video_collection),
                  label: const Text("Video"),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    handleVideoCapture(context);
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
    if (icon == null) {
      return TextButton(
        onPressed: disabled ? null : () => selectOptions(context),
        child: Text(text!),
      );
    }

    return IconButton.filled(
      onPressed: disabled ? null : () => selectOptions(context),
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
}
