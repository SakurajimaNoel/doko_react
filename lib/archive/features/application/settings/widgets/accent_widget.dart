import 'package:doko_react/archive/core/provider/theme_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccentWidget extends StatefulWidget {
  const AccentWidget({
    super.key,
  });

  @override
  State<AccentWidget> createState() => _AccentWidgetState();
}

class _AccentWidgetState extends State<AccentWidget> {
  late final ThemeProvider _themeProvider;
  late Color _currentColor;
  Color? _tempColor;

  @override
  void initState() {
    super.initState();

    _themeProvider = context.read<ThemeProvider>();
    _currentColor = _themeProvider.accent;
    _tempColor = _currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentColor,
          ),
        ),
        TextButton(
          onPressed: _openColorPicker,
          child: const Text('Change Accent'),
        ),
      ],
    );
  }

  Future<void> _openColorPicker() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Accent Color'),
          content: SizedBox(
            width: double.maxFinite,
            height: 340,
            child: ColorPicker(
              color: _tempColor!,
              onColorChanged: (Color newColor) {
                setState(() {
                  _tempColor = newColor;
                });
                _themeProvider.changeAccent(newColor);
              },
              borderRadius: 20,
              spacing: 10,
              runSpacing: 10,
              wheelDiameter: 250,
              wheelWidth: 25,
              pickersEnabled: const {
                ColorPickerType.primary: false,
                ColorPickerType.accent: true,
                ColorPickerType.wheel: true,
              },
              enableShadesSelection: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_tempColor);
              },
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      setState(() {
        _currentColor = selectedColor;
      });
      _themeProvider.changeAccent(selectedColor);
    } else {
      _themeProvider.changeAccent(_currentColor);
    }
  }
}
