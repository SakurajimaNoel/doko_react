import 'package:doko_react/core/data/video.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(List<XFile>) onSelection;
  final bool multiple;
  final bool video;
  final String displayText;
  final Icon? icon;
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
  });

  // function to select video from gallery
  Future<void> _selectVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedVideo = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (selectedVideo == null) return;

    await VideoActions.handleVideo(selectedVideo.path);

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
    if (multiple) {
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
        onPressed: () {
          _selectOptions(context);
        },
        child: Text(displayText),
      );
    }

    return IconButton.filled(
      onPressed: () {
        _selectOptions(context);
      },
      icon: icon!,
    );
  }
}
