import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/theme/theme_bloc.dart';
import 'package:doko_react/features/settings/presentation/widgets/heading/settings_heading.dart';
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
                  context.read<ThemeBloc>().add(ThemeChangeEvent(
                        selectedMode: newSelection.first,
                      ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
