import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  // function to call when media item is selected
  final Function(List<XFile>) onSelection;

  // boolean field when allowing multiple images to select
  final bool multiple;

  // boolean field for disabling the main widget button
  final bool disabled;

  // boolean field to allow selecting video files
  final bool video;

  // text for text button when icon is not provided
  final String displayText;

  // icon to user for icon button otherwise default to text button
  final Icon? icon;

  // limiting the number of selection for images
  final int multipleLimit;

  final int _imageQuality = 75;

  const ImagePickerWidget(
    this.displayText, {
    super.key,
    required this.onSelection,
    this.multiple = false,
    this.video = false,
    this.icon,
    this.multipleLimit = 10,
    this.disabled = false,
  });

  // function to select video from gallery
  Future<void> _selectVideoFromGallery() async {
    if (multipleLimit <= 0) return;

    final ImagePicker picker = ImagePicker();
    final XFile? selectedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (selectedVideo == null) return;

    onSelection([selectedVideo]);
  }

  // function to select multiple images from device gallery
  Future<void> _selectMultipleImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      limit: multipleLimit,
      imageQuality: _imageQuality,
    );

    if (images.isEmpty) return;

    onSelection(images);
  }

  // function to select single image from gallery
  Future<void> _selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: _imageQuality,
    );

    if (image == null) return;

    // trim video here

    onSelection([image]);
  }

  // function to click picture and use the resulting image from camera
  Future<void> _selectImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _imageQuality,
    );

    if (image == null) return;

    onSelection([image]);
  }

  void _handleVideo(BuildContext context) {
    _selectVideoFromGallery();

    Navigator.pop(context);
  }

  void _handleGallery(BuildContext context) {
    if (multiple && multipleLimit > 1) {
      _selectMultipleImagesFromGallery();
    } else {
      _selectImageFromGallery();
    }

    Navigator.pop(context);
  }

  void _handleCamera(BuildContext context) {
    _selectImageFromCamera();

    Navigator.pop(context);
  }

  // function to handle bottom sheet modal
  void _selectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                onPressed: () {
                  _handleGallery(context);
                },
                icon: const Icon(Icons.photo),
                label: const Text("Gallery"),
              ),
              if (!multiple)
                FilledButton.tonalIcon(
                  onPressed: () {
                    _handleCamera(context);
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Camera"),
                ),
              if (video)
                FilledButton.tonalIcon(
                  onPressed: () {
                    _handleVideo(context);
                  },
                  icon: const Icon(Icons.video_collection),
                  label: const Text("Video"),
                ),
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
        onPressed: disabled
            ? null
            : () {
                _selectOptions(context);
              },
        child: Text(displayText),
      );
    }

    return IconButton.filled(
      onPressed: disabled
          ? null
          : () {
              _selectOptions(context);
            },
      icon: icon!,
    );
  }
}
