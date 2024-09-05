import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(List<XFile>) onSelection;
  final bool multiple;
  final String displayText;

  const ImagePickerWidget(
    this.displayText, {
    super.key,
    required this.onSelection,
    this.multiple = false,
  });

  // function to select multiple images from device gallery
  Future<void> _selectMultipleImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    onSelection(images);
  }

  // function to select single image from gallery
  Future<void> _selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    onSelection([image]);
  }

  // function to click picture and use the resulting image from camera
  Future<void> _selectImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    onSelection([image]);
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _selectOptions(context);
      },
      child: Text(displayText),
    );
  }
}
