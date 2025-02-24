import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/theme/theme_bloc.dart';
import 'package:doko_react/features/settings/presentation/widgets/heading/settings_heading.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsHeading.large("Theme Settings"),
        SizedBox(
          height: Constants.gap * 0.5,
        ),
        SettingsHeading("Application Mode"),
        SizedBox(
          height: Constants.gap * 0.25,
        ),
        _ThemeWidget(),
        SizedBox(
          height: Constants.gap * 0.75,
        ),
        SettingsHeading("Application Accent"),
        SizedBox(
          height: Constants.gap * 0.5,
        ),
        _AccentWidget(),
      ],
    );
  }
}

class _ThemeWidget extends StatelessWidget {
  const _ThemeWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<ThemeBloc, ThemeState>(
            buildWhen: (previousState, state) {
              return previousState.mode != state.mode;
            },
            builder: (context, state) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.sunny),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.system_security_update_good_rounded),
                  ),
                ],
                selected: {state.mode},
                onSelectionChanged: (newSelection) {
                  context.read<ThemeBloc>().add(
                        ThemeChangeEvent(
                          selectedMode: newSelection.first,
                        ),
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AccentWidget extends StatefulWidget {
  const _AccentWidget();

  @override
  State<_AccentWidget> createState() => _AccentWidgetState();
}

class _AccentWidgetState extends State<_AccentWidget> {
  late Color accent = context.read<ThemeBloc>().state.accent;

  void updateGlobalAccent(Color accent) {
    context.read<ThemeBloc>().add(ThemeChangeAccentEvent(
          selectedAccent: accent,
        ));
    setState(() {
      this.accent = accent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(builder: (context) {
          final currentAccentColor =
              context.select((ThemeBloc bloc) => bloc.state.accent);
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentAccentColor,
            ),
          );
        }),
        TextButton(
          onPressed: openColorPicker,
          child: const Text('Change Accent'),
        ),
      ],
    );
  }

  Future<void> openColorPicker() async {
    final currentAccentColor = context.read<ThemeBloc>().state.accent;
    Color previousSelection = currentAccentColor;

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Accent Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ColorPicker(
                color: accent,
                onColorChanged: (Color newColor) {
                  updateGlobalAccent(newColor);
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
                enableShadesSelection: true,
              ),
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
                Navigator.of(context).pop(currentAccentColor);
              },
            ),
          ],
        );
      },
    );

    if (selectedColor == null) {
      updateGlobalAccent(previousSelection);
    }
  }
}
