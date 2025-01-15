import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/preferences/preferences_bloc.dart';
import 'package:doko_react/features/settings/presentation/widgets/heading/settings_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationSettings extends StatefulWidget {
  const ApplicationSettings({super.key});

  @override
  State<ApplicationSettings> createState() => _ApplicationSettingsState();
}

class _ApplicationSettingsState extends State<ApplicationSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeading.large("Application Settings"),
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        const SettingsHeading("Save Media to Device"),
        const Text(
            "Enable this to save captured photos and videos to your device's storage."),
        Builder(builder: (context) {
          bool selected = context
              .select((PreferencesBloc bloc) => bloc.state.saveCapturedMedia);

          const WidgetStateProperty<Icon> thumbIcon =
              WidgetStateProperty<Icon>.fromMap(
            <WidgetStatesConstraint, Icon>{
              WidgetState.selected: Icon(Icons.check),
              WidgetState.any: Icon(Icons.close),
            },
          );

          return Switch(
            value: selected,
            thumbIcon: thumbIcon,
            onChanged: (bool value) {
              context
                  .read<PreferencesBloc>()
                  .add(PreferencesSaveMediaToggleEvent());
            },
          );
        })
      ],
    );
  }
}
